/**
 * @id c/misra/invalid-operation-on-unlocked-mutex
 * @name RULE-22-17: No thread shall unlock a mutex or call cnd_wait() or cnd_timedwait() for a mutex it has not locked
 * @description No thread shall unlock a mutex or call cnd_wait() or cnd_timedwait() for a mutex it
 *              has not locked before.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-22-17
 *       correctness
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.SubObjects
import codingstandards.cpp.Concurrency
import codingstandards.cpp.dominance.BehavioralSet

/* A call to mtx_unlock() or cnd_wait() or cnd_timedwait(), which require a locked mutex */
class RequiresLockOperation extends FunctionCall {
  SubObject mutex;

  RequiresLockOperation() {
    exists(CMutexFunctionCall mutexCall | this = mutexCall |
      mutexCall.isUnlock() and
      mutex.getAnAddressOfExpr() = mutexCall.getLockExpr()
    )
    or
    exists(CConditionOperation condOp | this = condOp |
      mutex.getAnAddressOfExpr() = condOp.getMutexExpr()
    )
  }

  SubObject getMutex() { result = mutex }
}

/* A config to search for a dominating set that locks the mutex before the operation */
module LockDominatingSetConfig implements DominatingSetConfigSig<RequiresLockOperation> {
  predicate isTargetBehavior(ControlFlowNode node, RequiresLockOperation op) {
    exists(CMutexFunctionCall mutexCall | node = mutexCall |
      mutexCall.isLock() and
      mutexCall.getLockExpr() = op.getMutex().getAnAddressOfExpr()
    )
  }

  predicate isBlockingBehavior(ControlFlowNode node, RequiresLockOperation op) {
    // If we find a branch that explicitly unlocks the mutex, we should not look for an earlier
    // call to lock that mutex.
    exists(CMutexFunctionCall mutexCall | node = mutexCall |
      mutexCall.isUnlock() and
      mutexCall.getLockExpr() = op.getMutex().getAnAddressOfExpr()
    )
  }
}

import DominatingBehavioralSet<RequiresLockOperation, LockDominatingSetConfig> as DominatingSet

from RequiresLockOperation operation, SubObject mutex
where
  not isExcluded(operation, Concurrency9Package::invalidOperationOnUnlockedMutexQuery()) and
  mutex = operation.getMutex() and
  not DominatingSet::isDominatedByBehavior(operation)
select operation, "Invalid operation on mutex '$@' not locked by the current thread.",
  mutex.getRootIdentity(), mutex.toString()
