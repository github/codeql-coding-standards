/**
 * @id c/cert/wrap-functions-that-can-fail-spuriously-in-loop
 * @name CON41-C: Wrap functions that can fail spuriously in a loop
 * @description Failing to wrap a function that may fail spuriously may result in unreliable program
 *              behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/con41-c
 *       correctness
 *       concurrency
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Concurrency

from AtomicCompareExchange ace
where
  not isExcluded(ace, Concurrency3Package::wrapFunctionsThatCanFailSpuriouslyInLoopQuery()) and
  (
    forex(StmtParent sp | sp = ace.getStmt() | not sp.(Stmt).getParentStmt*() instanceof Loop)
    or
    forex(Expr e | e = ace.getExpr() | not e.getEnclosingStmt().getParentStmt*() instanceof Loop)
  )
select ace, "Function that can spuriously fail not wrapped in a loop."
