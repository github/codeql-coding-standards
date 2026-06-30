/**
 * @id c/misra/condition-variable-used-with-multiple-mutexes
 * @name RULE-22-19: A condition variable shall be associated with at most one mutex object
 * @description Standard library functions cnd_wait() and cnd_timedwait() shall specify the same
 *              mutex object for each condition object in all calls.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-19
 *       correctness
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.SubObjects
import codingstandards.cpp.Concurrency

bindingset[cond, mutex]
int countMutexesForConditionVariable(SubObject cond, SubObject mutex) {
  result =
    count(CConditionOperation call |
      call.getConditionExpr() = cond.getAnAddressOfExpr() and
      call.getMutexExpr() = mutex.getAnAddressOfExpr()
    )
}

bindingset[cond, mutex]
predicate conditionVariableUsesMutex(SubObject cond, SubObject mutex) {
  countMutexesForConditionVariable(cond, mutex) > 0
}

bindingset[cond, n]
SubObject nthMutexForConditionVariable(SubObject cond, int n) {
  result =
    rank[n](SubObject mutex |
      conditionVariableUsesMutex(cond, mutex)
    |
      mutex order by countMutexesForConditionVariable(cond, mutex), mutex.toString()
    )
}

bindingset[cond, mutex]
CConditionOperation firstCallForConditionMutex(SubObject cond, SubObject mutex) {
  result =
    rank[1](CConditionOperation call |
      call.getConditionExpr() = cond.getAnAddressOfExpr() and
      call.getMutexExpr() = mutex.getAnAddressOfExpr()
    |
      call order by call.getFile().getAbsolutePath(), call.getLocation().getStartLine()
    )
}

from
  SubObject cond, CConditionOperation useOne, SubObject mutexOne, CConditionOperation useTwo,
  SubObject mutexTwo
where
  not isExcluded(cond.getRootIdentity(),
    Concurrency9Package::conditionVariableUsedWithMultipleMutexesQuery()) and
  mutexOne = nthMutexForConditionVariable(cond, 1) and
  mutexTwo = nthMutexForConditionVariable(cond, 2) and
  useOne = firstCallForConditionMutex(cond, mutexOne) and
  useTwo = firstCallForConditionMutex(cond, mutexOne)
select useOne,
  "Condition variable $@ associated with multiple mutexes, operation uses mutex $@ while $@ uses other mutex $@.",
  cond.getRootIdentity(), cond.toString(), mutexOne.getRootIdentity(), mutexOne.toString(), useTwo,
  "another operation", mutexTwo.getRootIdentity(), mutexTwo.toString()
