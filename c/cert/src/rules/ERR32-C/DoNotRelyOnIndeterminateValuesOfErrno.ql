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

class SignalCall extends FunctionCall {
  SignalCall() { this.getTarget().hasGlobalName("signal") }
}

/**
 * Models signal handlers that call signal()
 */
class SignalCallingHandler extends Function {
  SignalCall sh;

  SignalCallingHandler() {
    // is a signal handler
    this = sh.getArgument(1).(FunctionAccess).getTarget() and
    // calls signal()
    this.calls*(any(SignalCall c).getTarget())
  }

  SignalCall getHandler() { result = sh }
}

from ErrnoRead errno, SignalCall h
where
  not isExcluded(errno, Contracts5Package::doNotRelyOnIndeterminateValuesOfErrnoQuery()) and
  // errno read in the handler
  exists(SignalCallingHandler sc |
    sc.getHandler() = h and
    (
      sc.calls*(errno.getEnclosingFunction())
      or
      // errno is read after the handle
      errno.(ControlFlowNode).getAPredecessor+() = sc.getHandler()
    )
  )
select errno, "`errno` has indeterminate value after this $@.", h, h.toString()
