/**
 * @id c/misra/thread-storage-pointer-initialized-inside-thread
 * @name RULE-22-20: Thread specific storage pointers shall be initialized deterministically
 * @description Thread specific storage pointers initialized inside of threads may result in
 *              indeterministic state.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-22-20
 *       readability
 *       maintainability
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Concurrency

from TSSCreateFunctionCall tssCreate, ThreadedFunction thread
where
  not isExcluded(tssCreate, Concurrency8Package::mutexInitializedInsideThreadQuery()) and
  thread.calls*(tssCreate.getEnclosingFunction())
select tssCreate,
  "Thread specific storage object initialization reachable from threaded function '$@'.", thread,
  thread.getName()
