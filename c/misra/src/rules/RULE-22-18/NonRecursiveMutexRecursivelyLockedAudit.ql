/**
 * @id c/misra/non-recursive-mutex-recursively-locked-audit
 * @name RULE-22-18: (Audit) Non-recursive mutexes shall not be recursively locked
 * @description Mutexes that may be initialized without mtx_recursive shall not be locked by a
 *              thread that may have previously locked it.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-22-18
 *       correctness
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/audit
 *       external/misra/obligation/required
 */

import cpp
import codeql.util.Boolean
import codingstandards.c.misra
import codingstandards.c.SubObjects
import codingstandards.cpp.Concurrency
import codingstandards.cpp.Type

predicate isTrackableMutex(CMutexFunctionCall lockCall, Boolean recursive) {
  exists(SubObject mutex |
    lockCall.getLockExpr() = mutex.getAnAddressOfExpr() and
    mutex.isPrecise() and
    forex(C11MutexSource init | init.getMutexExpr() = mutex.getAnAddressOfExpr() |
      if init.isRecursive() then recursive = true else recursive = false
    )
  )
}

predicate definitelyDifferentMutexes(CMutexFunctionCall lockCall, CMutexFunctionCall coveredByLock) {
  exists(SubObject a, SubObject b |
    lockCall.getLockExpr() = a.getAnAddressOfExpr() and
    coveredByLock.getLockExpr() = b.getAnAddressOfExpr() and
    not a = b
  )
}

from LockProtectedControlFlowNode n, CMutexFunctionCall lockCall, CMutexFunctionCall coveredByLock
where
  not isExcluded(n, Concurrency9Package::nonRecursiveMutexRecursivelyLockedAuditQuery()) and
  lockCall = n and
  coveredByLock = n.coveredByLock() and
  not coveredByLock = lockCall and
  // If mutexes are provably different objects, they do not need to be audited
  not definitelyDifferentMutexes(lockCall, coveredByLock) and
  (
    // If either mutex is not trackable, it should be audited
    not isTrackableMutex(lockCall, _) or
    not isTrackableMutex(coveredByLock, _)
  ) and
  not (
    // If either mutex is definitely recursive, it does not need to be audited
    isTrackableMutex(lockCall, true) or
    isTrackableMutex(coveredByLock, true)
  )
select n, "Mutex locked after it was already $@.", coveredByLock, "previously locked"
