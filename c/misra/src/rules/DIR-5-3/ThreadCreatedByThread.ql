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

Function callers(Function f) { result = f.getACallToThisFunction().getEnclosingFunction() }

class ThreadReachableFunction extends Function {
  /* The root threaded function from which this function is reachable */
  Function threadRoot;

  ThreadReachableFunction() {
    exists(CThreadCreateCall tc |
      tc.getFunction() = callers*(this) and
      threadRoot = tc.getFunction()
    )
  }

  /* Get the root threaded function from which this function is reachable */
  Function getThreadRoot() { result = threadRoot }
}

from CThreadCreateCall tc, ThreadReachableFunction enclosingFunction, Function threadRoot
where
  not isExcluded(tc, Concurrency6Package::threadCreatedByThreadQuery()) and
  enclosingFunction = tc.getEnclosingFunction() and
  threadRoot = enclosingFunction.getThreadRoot()
select tc, "Thread creation call reachable from threaded function '$@'.", threadRoot,
  threadRoot.toString()