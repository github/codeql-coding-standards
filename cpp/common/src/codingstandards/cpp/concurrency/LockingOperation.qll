import cpp
import semmle.code.cpp.dataflow.TaintTracking

abstract class LockingOperation extends FunctionCall {
  /**
   * Returns the target of the lock underlying this RAII-style lock.
   */
  abstract Variable getLock();

  /**
   * Returns the lock underlying this RAII-style lock.
   */
  abstract Expr getLockExpr();

  /**
   * Holds if this is a lock operation
   */
  abstract predicate isLock();

  /**
   * Holds if this is an unlock operation
   */
  abstract predicate isUnlock();

  /**
   * Holds if this locking operation is really a locking operation within a
   * designated locking operation. This library assumes the underlying locking
   * operations are implemented correctly in that calling a `LockingOperation`
   * results in the creation of a singular lock.
   */
  predicate isLockingOperationWithinLockingOperation(LockingOperation inner) {
    exists(LockingOperation outer | outer.getTarget() = inner.getEnclosingFunction())
  }
}

/**
 * Common base class providing an interface into function call
 * based mutex locks.
 */
abstract class MutexFunctionCall extends LockingOperation {
  abstract predicate isRecursive();

  abstract predicate isSpeculativeLock();

  abstract predicate unlocks(MutexFunctionCall fc);
}

/**
 *  Models calls to various mutex types found in CPP.
 */
class CPPMutexFunctionCall extends MutexFunctionCall {
  VariableAccess var;

  CPPMutexFunctionCall() {
    getTarget()
        .(MemberFunction)
        .getDeclaringType()
        .hasQualifiedName("std",
          ["mutex", "timed_mutex", "shared_timed_mutex", "recursive_mutex", "recursive_timed_mutex"]) and
    var = getQualifier()
  }

  /**
   * Holds if this mutex is a recursive mutex.
   */
  override predicate isRecursive() {
    getTarget()
        .(MemberFunction)
        .getDeclaringType()
        .hasQualifiedName("std", ["recursive_mutex", "recursive_timed_mutex"])
  }

  /**
   * Holds if this `CPPMutexFunctionCall` is a lock.
   */
  override predicate isLock() {
    not isLockingOperationWithinLockingOperation(this) and
    getTarget().getName() = "lock"
  }

  /**
   * Holds if this `CPPMutexFunctionCall` is a speculative lock, defined as calling
   * one of the speculative locking functions such as `try_lock`.
   */
  override predicate isSpeculativeLock() {
    getTarget().getName() in [
        "try_lock", "try_lock_for", "try_lock_until", "try_lock_shared_for", "try_lock_shared_until"
      ]
  }

  /**
   * Returns the lock to which this `CPPMutexFunctionCall` refers to.
   */
  override Variable getLock() { result = getQualifier().(VariableAccess).getTarget() }

  /**
   * Returns the qualifier for this `CPPMutexFunctionCall`.
   */
  override Expr getLockExpr() { result = var }

  /**
   * Holds if this is a `unlock` and *may* unlock the previously locked `MutexFunctionCall`.
   * This predicate does not check that the mutex is currently locked.
   */
  override predicate unlocks(MutexFunctionCall fc) {
    isUnlock() and
    fc.getQualifier().(VariableAccess).getTarget() = getQualifier().(VariableAccess).getTarget()
  }

  /**
   * Holds if this is an unlock call.
   */
  override predicate isUnlock() { getTarget().getName() = "unlock" }
}

/**
 *  Models calls to various mutex types specialized to C code.
 */
class CMutexFunctionCall extends MutexFunctionCall {
  Expr arg;

  CMutexFunctionCall() {
    // the non recursive kinds
    getTarget().getName() = ["mtx_lock", "mtx_unlock", "mtx_timedlock", "mtx_trylock"] and
    arg = getArgument(0)
  }

  /**
   * Holds if this mutex is a recursive mutex.
   */
  override predicate isRecursive() { none() }

  /**
   * Holds if this `CMutexFunctionCall` is a lock.
   */
  override predicate isLock() {
    not isLockingOperationWithinLockingOperation(this) and
    getTarget().getName() = ["mtx_lock", "mtx_timedlock", "mtx_trylock"]
  }

  /**
   * Holds if this `CMutexFunctionCall` is a speculative lock, defined as calling
   * one of the speculative locking functions such as `try_lock`.
   */
  override predicate isSpeculativeLock() {
    getTarget().getName() in ["mtx_timedlock", "mtx_trylock"]
  }

  /**
   * Returns the `Variable` to which this `CMutexFunctionCall` refers to. For this
   * style of lock it can reference a number of different variables.
   */
  override Variable getLock() {
    exists(VariableAccess va |
      TaintTracking::localTaint(DataFlow::exprNode(va), DataFlow::exprNode(getLockExpr())) and
      result = va.getTarget()
    )
  }

  /**
   * Returns the expression for this `CMutexFunctionCall`.
   */
  override Expr getLockExpr() { result = arg }

  /**
   * Holds if this is a `unlock` and *may* unlock the previously locked `CMutexFunctionCall`.
   * This predicate does not check that the mutex is currently locked.
   */
  override predicate unlocks(MutexFunctionCall fc) {
    isUnlock() and
    fc.getLock() = getLock()
  }

  /**
   * Holds if this is an unlock call.
   */
  override predicate isUnlock() { getTarget().getName() = "mtx_unlock" }
}

/**
 * Models a RAII-Style lock.
 */
class RAIIStyleLock extends LockingOperation {
  VariableAccess lock;

  RAIIStyleLock() {
    (
      getTarget().getDeclaringType().hasQualifiedName("std", "lock_guard") or
      getTarget().getDeclaringType().hasQualifiedName("std", "unique_lock") or
      getTarget().getDeclaringType().hasQualifiedName("std", "scoped_lock")
    ) and
    (
      lock = getArgument(0).getAChild*()
      or
      this instanceof DestructorCall and
      exists(RAIIStyleLock constructor |
        constructor = getQualifier().(VariableAccess).getTarget().getInitializer().getExpr() and
        lock = constructor.getArgument(0).getAChild*()
      )
    )
  }

  /**
   * Holds if this is a lock operation
   */
  override predicate isLock() {
    not isLockingOperationWithinLockingOperation(this) and
    this instanceof ConstructorCall and
    lock = getArgument(0).getAChild*() and
    // defer_locks don't cause a lock
    not exists(Expr exp |
      exp = getArgument(1) and
      exp.(VariableAccess)
          .getTarget()
          .getUnderlyingType()
          .(Class)
          .hasQualifiedName("std", "defer_lock_t")
    )
  }

  /**
   * Holds if this is an unlock operation
   */
  override predicate isUnlock() { this instanceof DestructorCall }

  /**
   * Returns the target of the lock underlying this RAII-style lock.
   */
  override Variable getLock() { result = lock.getTarget() }

  /**
   * Returns the lock underlying this RAII-style lock.
   */
  override Expr getLockExpr() { result = lock }
}
