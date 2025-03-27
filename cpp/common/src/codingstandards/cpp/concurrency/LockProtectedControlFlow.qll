import cpp
private import codingstandards.cpp.concurrency.ControlFlow
private import codingstandards.cpp.concurrency.LockingOperation

/**
 * Models a `ControlFlowNode` that is protected by some sort of lock.
 */
class LockProtectedControlFlowNode extends ThreadedCFN {
  FunctionCall lockingFunction;

  LockProtectedControlFlowNode() {
    exists(LockingOperation lock |
      // there is a node that is a lock
      lockingFunction = lock and
      lock.isLock() and
      // this node should be a successor of this lock
      this = getAThreadContextAwareSuccessor(lock) and
      // and there should not exist a predecessor of this
      // node that is an unlock. Since we are doing thread context
      // aware tracking it is easier to go forwards than backwards
      // in constructing the call graph. Thus we can define predecessor
      // in terms of a node that is a successor of the lock but NOT a
      // successor of the current node.
      not exists(ControlFlowNode unlock |
        // it's an unlock
        unlock = getAThreadContextAwarePredecessor(lock, this) and
        unlock.(MutexFunctionCall).isUnlock() and
        // note that we don't check that it's the same lock -- this is left
        // to the caller to enforce this condition.
        // Because of the way that `getAThreadContextAwarePredecessor` works, it is possible
        // for operations PAST it to be technically part of the predecessors.
        // Thus, we need to make sure that this node is a
        // successor of the unlock in the CFG
        getAThreadContextAwareSuccessor(unlock) = this
      ) and
      (lock instanceof MutexFunctionCall implies not this.(MutexFunctionCall).isUnlock())
    )
  }

  /**
   * The `MutexFunctionCall` holding the lock that locks this node.
   */
  FunctionCall coveredByLock() { result = lockingFunction }

  /**
   * The lock underlying this `LockProtectedControlFlowNode`.
   */
  Variable getAProtectingLock() { result = lockingFunction.(LockingOperation).getLock() }
}
