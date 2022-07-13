import cpp
import semmle.code.cpp.dataflow.TaintTracking

/**
 * Models CFG nodes which should be added to a thread context.
 */
abstract class ThreadedCFGPathExtension extends ControlFlowNode {
  /**
   * Returns the next `ControlFlowNode` in this thread context.
   */
  abstract ControlFlowNode getNext();
}

/**
 * Models a `FunctionCall` invoked from a threaded context.
 */
class ThreadContextFunctionCall extends FunctionCall, ThreadedCFGPathExtension {
  override ControlFlowNode getNext() { getTarget().getEntryPoint() = result }
}

/**
 * Models a specialized `FunctionCall` that may create a thread.
 */
abstract class ThreadCreationFunction extends FunctionCall, ThreadedCFGPathExtension {
  /**
   * Returns the function that will be invoked.
   */
  abstract Function getFunction();
}

/**
 * Models a call to a thread constructor via `std::thread`.
 */
class ThreadConstructorCall extends ConstructorCall, ThreadCreationFunction {
  Function f;

  ThreadConstructorCall() {
    getTarget().getDeclaringType().hasQualifiedName("std", "thread") and
    f = getArgument(0).(FunctionAccess).getTarget()
  }

  /**
   * Returns the function that will be invoked by this `std::thread`.
   */
  override Function getFunction() { result = f }

  override ControlFlowNode getNext() { result = getFunction().getEntryPoint() }
}

/**
 * Models a call to a thread constructor via `std::thread`.
 */
class C11ThreadCreateCall extends ThreadCreationFunction {
  Function f;

  C11ThreadCreateCall() {
    getTarget().getName() = "thrd_create" and
    (
      f = getArgument(1).(FunctionAccess).getTarget() or
      f = getArgument(1).(AddressOfExpr).getOperand().(FunctionAccess).getTarget()
    )
  }

  /**
   * Returns the function that will be invoked by this thread.
   */
  override Function getFunction() { result = f }

  override ControlFlowNode getNext() { result = getFunction().getEntryPoint() }
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
    (
      // the non recursive kinds
      getTarget().(MemberFunction).getDeclaringType().hasQualifiedName("std", "mutex") or
      getTarget().(MemberFunction).getDeclaringType().hasQualifiedName("std", "timed_mutex") or
      getTarget().(MemberFunction).getDeclaringType().hasQualifiedName("std", "shared_timed_mutex") or
      // the recursive ones
      getTarget().(MemberFunction).getDeclaringType().hasQualifiedName("std", "recursive_mutex") or
      getTarget()
          .(MemberFunction)
          .getDeclaringType()
          .hasQualifiedName("std", "recursive_timed_mutex")
    ) and
    var = getQualifier()
  }

  /**
   * Holds if this mutex is a recursive mutex.
   */
  override predicate isRecursive() {
    getTarget().(MemberFunction).getDeclaringType().hasQualifiedName("std", "recursive_mutex") or
    getTarget().(MemberFunction).getDeclaringType().hasQualifiedName("std", "recursive_timed_mutex")
  }

  /**
   * Holds if this `CPPMutexFunctionCall` is a lock.
   */
  override predicate isLock() { getTarget().getName() = "lock" }

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
 * The thread-aware predecessor function is defined in terms of the thread aware
 * successor function. This is because it is simpler to construct the forward
 * paths of a thread's execution than the backwards paths. For this reason we
 * require a `start` and `end` node.
 *
 * The logic of this function is that a thread aware predecessor is one that
 * follows a `start` node, is not equal to the ending node, and does not follow
 * the `end` node. Such nodes can only be predecessors of `end`.
 *
 * For this reason this function requires a `start` node from which to start
 * considering something a predecessor of `end`.
 */
pragma[inline]
ControlFlowNode getAThreadContextAwarePredecessor(ControlFlowNode start, ControlFlowNode end) {
  result = getAThreadContextAwareSuccessor(start) and
  not result = getAThreadContextAwareSuccessor(end) and
  not result = end
}

/**
 * A predicate for finding successors of `ControlFlowNode`s that are aware of
 * the objects that my flow into a thread's context. This is achieved by adding
 * additional edges to thread entry points and function calls.
 */
ControlFlowNode getAThreadContextAwareSuccessorR(ControlFlowNode cfn) {
  result = cfn.getASuccessor()
  or
  result = cfn.(ThreadedCFGPathExtension).getNext()
}

ControlFlowNode getAThreadContextAwareSuccessor(ControlFlowNode m) {
  result = getAThreadContextAwareSuccessorR*(m) and
  // for performance reasons we handle back edges by enforcing a lexical
  // ordering restriction on these nodes if they are both in
  // the same loop. One way of doing this is as follows:
  //
  // ````and (
  //   exists(Loop loop |
  //     loop.getAChild*() = m and
  //     loop.getAChild*() = result
  //   )
  //   implies
  //   not result.getLocation().isBefore(m.getLocation())
  // )```
  // In this implementation we opt for the more generic form below
  // which seems to have reasonable performance.
  (
    m.getEnclosingStmt().getParentStmt*() = result.getEnclosingStmt().getParentStmt*()
    implies
    not exists(Location l1, Location l2 |
      l1 = result.getLocation() and
      l2 = m.getLocation()
    |
      l1.getEndLine() < l2.getStartLine()
      or
      l1.getStartLine() = l2.getEndLine() and
      l1.getEndColumn() < l2.getStartColumn()
    )
  )
}

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
}

/**
 * Models a RAII-Style lock.
 */
class RAIIStyleLock extends LockingOperation {
  VariableAccess lock;
  Element e;

  RAIIStyleLock() {
    (
      getTarget().getDeclaringType().hasQualifiedName("std", "lock_guard") or
      getTarget().getDeclaringType().hasQualifiedName("std", "unique_lock") or
      getTarget().getDeclaringType().hasQualifiedName("std", "scoped_lock")
    )
  }

  /**
   * Holds if this is a lock operation
   */
  override predicate isLock() {
    this instanceof ConstructorCall and
    lock = getArgument(0).getAChild() and
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

/**
 * Models a function that may be executed by some thread.
 */
abstract class ThreadedFunction extends Function { }

/**
 * Models a function that may be executed by some thread via
 * C++ standard classes.
 */
class CPPThreadedFunction extends ThreadedFunction {
  CPPThreadedFunction() { exists(ThreadConstructorCall tcc | tcc.getFunction() = this) }
}

/**
 * Models a function that may be executed by some thread via
 * C11 standard functions.
 */
class C11ThreadedFunction extends ThreadedFunction {
  C11ThreadedFunction() { exists(C11ThreadCreateCall cc | cc.getFunction() = this) }
}

/**
 * Models a control flow node within a function that may be executed by some
 * thread.
 */
class ThreadedCFN extends ControlFlowNode {
  ThreadedCFN() {
    exists(ThreadedFunction tf | this = getAThreadContextAwareSuccessor(tf.getEntryPoint()))
  }
}

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
        unlock.(MutexFunctionCall).isUnlock()
        // note that we don't check that it's the same lock -- this is left
        // to the caller to enforce this condition.
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

/**
 * Models a function that conditionally waits.
 */
abstract class ConditionalWait extends FunctionCall {}
/**
 * Models a function in CPP that will conditionally wait. 
 */
class CPPConditionalWait extends ConditionalWait {
  CPPConditionalWait() {
    exists(MemberFunction mf |
      mf = getTarget() and
      mf.getDeclaringType().hasQualifiedName("std", "condition_variable") and
      mf.getName() in ["wait", "wait_for", "wait_until"]
    )
  }
}

/**
 * Models a function in C that will conditionally wait. 
 */
class CConditionalWait extends ConditionalWait {
  CConditionalWait() {
    getTarget().getName() in ["cnd_wait"]
  }
}

/**
 * Models a call to a `std::thread` constructor that depends on a mutex.
 */
class MutexDependentThreadConstructor extends ThreadConstructorCall {
  Expr mutexExpr;

  MutexDependentThreadConstructor() {
    mutexExpr = getAnArgument() and
    mutexExpr.getUnderlyingType().stripType() instanceof MutexType
  }

  Expr dependentMutex() { result = mutexExpr }
}

/**
 * Models a call to a a `std::thread` join.
 */
class ThreadWait extends FunctionCall {
  VariableAccess var;

  ThreadWait() {
    getTarget().(MemberFunction).getDeclaringType().hasQualifiedName("std", "thread") and
    getTarget().getName() = "join"
  }
}
