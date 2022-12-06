/**
 * @id c/cert/do-not-rely-on-indeterminate-values-of-errno
 * @name ERR32-C: Do not rely on indeterminate values of errno
 * @description Do not rely on indeterminate values of errno. This may result in undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err32-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Errno
import semmle.code.cpp.controlflow.Guards

class SignalCall extends FunctionCall {
  SignalCall() { this.getTarget().hasGlobalName("signal") }
}

/**
 * A check on `signal` call return value
 * `if (signal(SIGINT, handler) == SIG_ERR)`
 */
class SignalCheckOperation extends EqualityOperation, GuardCondition {
  ControlFlowNode errorSuccessor;

  SignalCheckOperation() {
    this.getAnOperand() = any(MacroInvocation m | m.getMacroName() = "SIG_ERR").getExpr() and
    (
      this.getOperator() = "==" and
      this.controls(errorSuccessor, true)
      or
      this.getOperator() = "!=" and
      this.controls(errorSuccessor, false)
    )
  }

  ControlFlowNode getErrorSuccessor() { result = errorSuccessor }
}

/**
 * Models signal handlers that call signal() and return
 */
class SignalCallingHandler extends Function {
  SignalCall sh;

  SignalCallingHandler() {
    // is a signal handler
    this = sh.getArgument(1).(FunctionAccess).getTarget() and
    // calls signal() on the handled signal
    exists(SignalCall sCall |
      sCall.getEnclosingFunction() = this and
      DataFlow::localFlow(DataFlow::parameterNode(this.getParameter(0)),
        DataFlow::exprNode(sCall.getArgument(0))) and
      // does not abort on error
      not exists(SignalCheckOperation sCheck, FunctionCall abort |
        DataFlow::localExprFlow(sCall, sCheck.getAnOperand()) and
        abort.getTarget().hasGlobalName(["abort", "_Exit"]) and
        abort.getEnclosingElement*() = sCheck.getErrorSuccessor()
      )
    )
  }

  SignalCall getHandler() { result = sh }
}

from ErrnoRead errno, SignalCall h
where
  not isExcluded(errno, Contracts5Package::doNotRelyOnIndeterminateValuesOfErrnoQuery()) and
  exists(SignalCallingHandler sc | sc.getHandler() = h |
    // errno read in the handler
    sc.calls*(errno.getEnclosingFunction())
    or
    // errno is read after the handle returns
    sc.getHandler() = h and
    errno.getAPredecessor+() = h
  )
select errno, "`errno` has indeterminate value after this $@.", h, h.toString()
