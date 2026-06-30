/**
 * @id c/misra/thread-created-by-thread
 * @name DIR-5-3: Threads shall not be created by other threads
 * @description Creating threads within threads creates uncertainty in program behavior and
 *              concurrency overhead costs.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/dir-5-3
 *       external/misra/c/2012/amendment4
 *       correctness
 *       maintainability
 *       concurrency
 *       performance
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Concurrency

class CThreadRoot extends Function {
  CThreadCreateCall threadCreate;

  CThreadRoot() { threadCreate.getFunction() = this }

  /* Get a function which is reachable from this function */
  Function getAReachableFunction() { calls*(result) }

  CThreadCreateCall getACThreadCreateCall() { result = threadCreate }
}

from CThreadCreateCall tc, CThreadRoot threadRoot
where
  not isExcluded(tc, Concurrency6Package::threadCreatedByThreadQuery()) and
  tc.getEnclosingFunction() = threadRoot.getAReachableFunction()
select tc, "Thread creation call reachable from function '$@', which may also be $@.", threadRoot,
  threadRoot.toString(), threadRoot.getACThreadCreateCall(), "started as a thread"
