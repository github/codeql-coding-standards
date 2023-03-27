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
import codingstandards.c.Signal
import semmle.code.cpp.controlflow.Guards


/**
 * A check on `signal` call return value
 * `if (signal(SIGINT, handler) == SIG_ERR)`
 */
class SignalCheckOperation extends EqualityOperation, GuardCondition {
  BasicBlock errorSuccessor;

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

  BasicBlock getCheckedSuccessor() { result != errorSuccessor and result = this.getASuccessor() }

  BasicBlock getErrorSuccessor() { result = errorSuccessor }
}

/**
 * Models signal handlers that call signal() and return
 */
class SignalCallingHandler extends SignalHandler {
  SignalCallingHandler() {
    // calls signal() on the handled signal
    exists(SignalCall sCall |
      sCall.getEnclosingFunction() = this and
      DataFlow::localFlow(DataFlow::parameterNode(this.getParameter(0)),
        DataFlow::exprNode(sCall.getArgument(0))) and
      // does not abort on error
      not exists(SignalCheckOperation sCheck, AbortCall abort |
        DataFlow::localExprFlow(sCall, sCheck.getAnOperand()) and
        abort = sCheck.getErrorSuccessor().(BlockStmt).getStmt(0).(ExprStmt).getExpr()
      )
    )
  }
}

/**
 * CFG nodes preceeding `ErrnoRead`
 */
ControlFlowNode preceedErrnoRead(ErrnoRead er) {
  result = er
  or
  exists(ControlFlowNode mid |
    result = mid.getAPredecessor() and
    mid = preceedErrnoRead(er) and
    // stop recursion on calls to `abort` and `_Exit`
    not result instanceof AbortCall and
    // stop recursion on successful `SignalCheckOperation`
    not result = any(SignalCheckOperation o).getCheckedSuccessor()
  )
}

from ErrnoRead errno, SignalCall signal
where
  not isExcluded(errno, Contracts5Package::doNotRelyOnIndeterminateValuesOfErrnoQuery()) and
  exists(SignalCallingHandler handler |
    // errno read after the handler returns
    handler.getRegistration() = signal
    or
    // errno read inside the handler
    signal.getEnclosingFunction() = handler
  |
    signal = preceedErrnoRead(errno)
  )
select errno, "`errno` has indeterminate value after this $@.", signal, signal.toString()
