/**
 * @id c/cert/do-not-call-va-arg-on-a-va-list-that-has-an-indeterminate-value
 * @name MSC39-C: Do not call va_arg() on a va_list that has an indeterminate value
 * @description Do not call va_arg() on a va_list that has an indeterminate value.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/msc39-c
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p3
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Macro
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.ir.IR as IR

abstract class VaAccess extends VariableAccess {
  abstract DataFlow::Node getDfn();
}

/**
 * The argument of a call to `va_arg`
 */
class VaArgArg extends VaAccess {
  IR::NextVarArgInstruction nva;

  VaArgArg() { this = any(MacroInvocation m | m.getMacroName() = ["va_arg"]).getExpr().getChild(0) }

  override DataFlow::Node getDfn() {
    // Simply using `DataFlow::exprNode(this)` will not correctly find the IR nodes for this
    // `va_arg` usage, so we have to dig into the IR here ourselves to properly wire things up.
    //
    // The IR for a `va_arg(p)` looks as follows:
    //
    // rx_n = VariableAddress[p]
    // ...
    // ry_0 = Load[p] : &:rx_n
    // ry_1 = Load[?] : &:ry_n
    // ry_2 = NextVarArg : ry_1
    //
    // The last occurrence of `va_list` that we have dataflow to is `ry_0` via an `OperandNode`,
    // and the simplest attachment between the AST and the IR is through `ry_2` and our parent AST
    // node, the `__builtin_vararg(...)` call.
    exists(IR::Operand ry0, IR::Instruction ry1, IR::NextVarArgInstruction ry2 |
      ry2.getAnOperand().getDef() = ry1 and
      ry2.getAst() = this.getParent() and
      ry1.getAnOperand() = ry0 and
      result.(DataFlow::OperandNode).getOperand() = ry0
    )
  }
}

/**
 * The argument of a call to `va_end`
 */
class VaEndArg extends VaAccess {
  VaEndArg() { this = any(MacroInvocation m | m.getMacroName() = ["va_end"]).getExpr().getChild(0) }

  override DataFlow::Node getDfn() { result.asExpr() = this }
}

/**
 * Dataflow configuration for flow from between `va_list` usages.
 */
module VaArgConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node src) {
    src.asUninitialized() =
      any(VariableDeclarationEntry m | m.getType().hasName("va_list")).getVariable()
  }

  predicate isSink(DataFlow::Node sink) { exists(VaAccess va_acc | sink = va_acc.getDfn()) }
}

module VaArgFlow = DataFlow::Global<VaArgConfig>;

/**
 * Controlflow nodes preceeding a call to `va_arg`
 */
ControlFlowNode preceedsFC(VaAccess va_arg) {
  result = va_arg
  or
  exists(ControlFlowNode mid |
    result = mid.getAPredecessor() and
    mid = preceedsFC(va_arg) and
    // stop recursion on va_end on the same object
    not result =
      any(MacroInvocation m |
        m.getMacroName() = ["va_start"] and
        m.getExpr().getChild(0).(VariableAccess).getTarget() = va_arg.getTarget()
      ).getExpr()
  )
}

predicate sameSource(VaAccess e1, VaAccess e2) {
  exists(DataFlow::Node source |
    VaArgFlow::flow(source, e1.getDfn()) and
    VaArgFlow::flow(source, e2.getDfn())
  )
}

/**
 * Extracted to avoid poor magic join ordering on the `isExcluded` predicate.
 */
predicate query(VaAccess va_acc, VaArgArg va_arg, FunctionCall fc) {
  sameSource(va_acc, va_arg) and
  fc = preceedsFC(va_acc) and
  fc.getTarget().calls*(va_arg.getEnclosingFunction())
}

from VaAccess va_acc, VaArgArg va_arg, FunctionCall fc
where
  not isExcluded(va_acc,
    Contracts7Package::doNotCallVaArgOnAVaListThatHasAnIndeterminateValueQuery()) and
  query(va_acc, va_arg, fc)
select va_acc, "The value of " + va_acc.toString() + " is indeterminate after the $@.", fc,
  fc.toString()
