/**
 * @id c/misra/banned-dynamic-thread-creation
 * @name DIR-5-3: There shall be no dynamic thread creation
 * @description Creating threads outside of a well-defined program start-up phase creates
 *              uncertainty in program behavior and concurrency overhead costs.
 * @kind problem
 * @precision low
 * @problem.severity error
 * @tags external/misra/id/dir-5-3
 *       external/misra/c/2012/amendment4
 *       external/misra/c/audit
 *       correctness
 *       maintainability
 *       concurrency
 *       performance
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Concurrency

from CThreadCreateCall tc, Function enclosingFunction
where
  not isExcluded(tc, Concurrency6Package::bannedDynamicThreadCreationQuery()) and
  enclosingFunction = tc.getEnclosingFunction() and
  not enclosingFunction.getName() = "main"
select tc, "Possible dynamic creation of thread outside initialization in function '$@'.",
  enclosingFunction, enclosingFunction.toString()
