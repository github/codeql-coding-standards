/**
 * @id c/cert/do-not-return-from-a-computational-exception-handler
 * @name SIG35-C: Do not return from a computational exception signal handler
 * @description Do not return from a computational exception signal handler.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/sig35-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Signal
import semmle.code.cpp.dataflow.DataFlow

/**
 * CFG nodes preceeding a `ReturnStmt`
 */
ControlFlowNode reachesReturn(ReturnStmt return) {
  result = return
  or
  exists(ControlFlowNode mid |
    result = mid.getAPredecessor() and
    mid = reachesReturn(return) and
    // stop recursion on calls to `abort`, `_Exit` and "quick_exit"
    not result instanceof AbortCall
  )
}

from ReturnStmt return, ComputationalExceptionSignal e
where
  not isExcluded(return, SignalHandlersPackage::doNotReturnFromAComputationalExceptionHandlerQuery()) and
  exists(SignalHandler handler |
    handler = return.getEnclosingFunction() and
    // computational exception handler
    DataFlow::localExprFlow(e.getExpr(), handler.getRegistration().getArgument(0)) and
    // control flow reaches a return statement
    reachesReturn(return) = handler.getBlock()
  )
select return, "Do not return from a $@ signal handler.", e, "computational exception"
