/**
 * @id c/cert/do-not-call-va-arg-on-a-va-list-that-has-an-indeterminate-value
 * @name MSC39-C: Do not call va_arg() on a va_list that has an indeterminate value
 * @description Do not call va_arg() on a va_list that has an indeterminate value.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/msc39-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Macro
import semmle.code.cpp.dataflow.DataFlow

/**
 * The argument of a call to `va_arg`
 */
class VaArgArg extends Expr {
  VaArgArg() { this = any(MacroInvocation m | m.getMacroName() = ["va_arg"]).getExpr().getChild(0) }
}

/**
 * Dataflow configuration for flow from a library function
 * to a call of function `asctime`
 */
class VaArgConfig extends DataFlow::Configuration {
  VaArgConfig() { this = "VaArgConfig" }

  override predicate isSource(DataFlow::Node src) {
    src.asUninitialized() =
      any(VariableDeclarationEntry m | m.getType().hasName("va_list")).getVariable()
  }

  override predicate isSink(DataFlow::Node sink) { sink.asExpr() instanceof VaArgArg }
}

/**
 * Controlflow nodes preceeding a call to `va_arg`
 */
ControlFlowNode preceedsFC(VaArgArg va_arg) {
  result = va_arg
  or
  exists(ControlFlowNode mid |
    result = mid.getAPredecessor() and
    mid = preceedsFC(va_arg) and
    // stop recursion on va_end on the same object
    not result =
      any(MacroInvocation m |
        m.getMacroName() = ["va_end"] and
        m.getExpr().getChild(0).(VariableAccess).getTarget() = va_arg.(VariableAccess).getTarget()
      ).getExpr()
  )
}

predicate sameSource(VaArgArg va_arg1, VaArgArg va_arg2) {
  exists(VaArgConfig config, DataFlow::Node source |
    config.hasFlow(source, DataFlow::exprNode(va_arg1)) and
    config.hasFlow(source, DataFlow::exprNode(va_arg2))
  )
}

from VaArgArg va_arg1, VaArgArg va_arg2, FunctionCall fc
where
  not isExcluded(va_arg1,
    Contracts7Package::doNotCallVaArgOnAVaListThatHasAnIndeterminateValueQuery()) and
  sameSource(va_arg1, va_arg2) and
  fc = preceedsFC(va_arg1) and
  fc.getTarget().calls*(va_arg2.getEnclosingFunction())
select va_arg1, "The value of " + va_arg1.toString() + " is indeterminate after the $@.", fc,
  fc.toString()
