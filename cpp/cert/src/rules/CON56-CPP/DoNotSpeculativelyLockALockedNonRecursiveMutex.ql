/**
 * @id cpp/cert/do-not-speculatively-lock-a-locked-non-recursive-mutex
 * @name CON56-CPP: Do not speculatively lock a non-recursive mutex that is already owned by the calling thread
 * @description Speculatively locking a non-recursive mutex that is already owned by the calling
 *              thread can result in undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con56-cpp
 *       correctness
 *       concurrency
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p1
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Concurrency

from LockProtectedControlFlowNode n
where
  not isExcluded(n, ConcurrencyPackage::doNotSpeculativelyLockALockedNonRecursiveMutexQuery()) and
  // problematic nodes are ones where a lock is active and there is an attempt
  // to call a speculative locking function
  n.(MutexFunctionCall).isSpeculativeLock() and
  not n.(MutexFunctionCall).isRecursive() and
  n.getAProtectingLock() = n.(MutexFunctionCall).getLock()
select n, "Attempt to speculatively lock a non-recursive mutex while it is $@.", n.coveredByLock(),
  "already locked"
