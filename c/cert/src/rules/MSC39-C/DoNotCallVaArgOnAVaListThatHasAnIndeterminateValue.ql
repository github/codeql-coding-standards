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
import semmle.code.cpp.dataflow.DataFlow

abstract class VaAccess extends Expr { }

/**
 * The argument of a call to `va_arg`
 */
class VaArgArg extends VaAccess {
  VaArgArg() { this = any(MacroInvocation m | m.getMacroName() = ["va_arg"]).getExpr().getChild(0) }
}

/**
 * The argument of a call to `va_end`
 */
class VaEndArg extends VaAccess {
  VaEndArg() { this = any(MacroInvocation m | m.getMacroName() = ["va_end"]).getExpr().getChild(0) }
}

/**
 * Dataflow configuration for flow from a library function
 * to a call of function `asctime`
 */
module VaArgConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node src) {
    src.asUninitialized() =
      any(VariableDeclarationEntry m | m.getType().hasName("va_list")).getVariable()
  }

  predicate isSink(DataFlow::Node sink) { sink.asExpr() instanceof VaAccess }
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
        m.getExpr().getChild(0).(VariableAccess).getTarget() = va_arg.(VariableAccess).getTarget()
      ).getExpr()
  )
}

predicate sameSource(VaAccess e1, VaAccess e2) {
  exists(DataFlow::Node source |
    VaArgFlow::flow(source, DataFlow::exprNode(e1)) and
    VaArgFlow::flow(source, DataFlow::exprNode(e2))
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
