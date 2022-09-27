/**
 * @id c/cert/appropriate-thread-object-storage-durations
 * @name CON34-C: Declare objects shared between threads with appropriate storage durations
 * @description Accessing thread-local variables with automatic storage durations can lead to
 *              unpredictable program behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con34-c
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Concurrency
import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.commons.Alloc

from C11ThreadCreateCall tcc, StackVariable sv, Expr arg, Expr acc
where
  not isExcluded(tcc, Concurrency4Package::appropriateThreadObjectStorageDurationsQuery()) and
  tcc.getArgument(2) = arg and
  sv.getAnAccess() = acc and
  // a stack variable that is given as an argument to a thread
  TaintTracking::localTaint(DataFlow::exprNode(acc), DataFlow::exprNode(arg)) and
  // or isn't one of the allowed usage patterns
  not exists(Expr mfc |
    isAllocationExpr(mfc) and
    sv.getAnAssignedValue() = mfc and
    acc.getAPredecessor*() = mfc
  ) and
  not exists(TSSGetFunctionCall tsg, TSSSetFunctionCall tss, DataFlow::Node src |
    sv.getAnAssignedValue() = tsg and
    acc.getAPredecessor*() = tsg and
    // there should be dataflow from somewhere (the same somewhere)
    // into each of the first arguments
    DataFlow::localFlow(src, DataFlow::exprNode(tsg.getArgument(0))) and
    DataFlow::localFlow(src, DataFlow::exprNode(tss.getArgument(0)))
  )
select tcc, "$@ not declared with appropriate storage duration", arg, "Shared object"
