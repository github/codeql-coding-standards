/**
 * @id c/misra/non-recursive-mutex-recursively-locked
 * @name RULE-22-18: Non-recursive mutexes shall not be recursively locked
 * @description Mutexes initialized with mtx_init() without mtx_recursive shall not be locked by a
 *              thread that has previously locked it.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-18
 *       correctness
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.SubObjects
import codingstandards.cpp.Concurrency
import codingstandards.cpp.Type

from
  LockProtectedControlFlowNode n, CMutexFunctionCall lockCall, SubObject mutex,
  CMutexFunctionCall coveredByLock
where
  not isExcluded(n, Concurrency9Package::nonRecursiveMutexRecursivelyLockedQuery()) and
  lockCall = n and
  coveredByLock = n.coveredByLock() and
  not coveredByLock = lockCall and
  mutex.isPrecise() and
  coveredByLock.getLockExpr() = mutex.getAnAddressOfExpr() and
  lockCall.getLockExpr() = mutex.getAnAddressOfExpr() and
  forex(C11MutexSource init | init.getMutexExpr() = mutex.getAnAddressOfExpr() |
    not init.isRecursive()
  )
select n, "Non-recursive mutex " + mutex.toString() + " locked after it is $@.", coveredByLock,
  "already locked"
