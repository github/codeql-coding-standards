/**
 * @id c/misra/mutex-initialized-inside-thread
 * @name RULE-22-14: Thread synchronization objects shall be initialized deterministically
 * @description Mutex and condition objects initialized inside of threads may result in
 *              indeterministic state.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-22-14
 *       readability
 *       maintainability
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Concurrency

from C11MutexSource mutexCreate, ThreadedFunction thread
where
  not isExcluded(mutexCreate, Concurrency8Package::mutexInitializedInsideThreadQuery()) and
  thread.calls*(mutexCreate.getEnclosingFunction())
select mutexCreate, "Mutex initialization reachable from threaded function '$@'.", thread,
  thread.getName()
