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
 * Models a call to a thread constructor via `thrd_create`.
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

/**
 * Models a function that conditionally waits.
 */
abstract class ConditionalWait extends FunctionCall { }

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
  CConditionalWait() { getTarget().getName() in ["cnd_wait"] }
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
 * Models thread waiting functions.
 */
abstract class ThreadWait extends FunctionCall { }

/**
 * Models a call to a `std::thread` join.
 */
class CPPThreadWait extends ThreadWait {
  VariableAccess var;

  CPPThreadWait() {
    getTarget().(MemberFunction).getDeclaringType().hasQualifiedName("std", "thread") and
    getTarget().getName() = "join"
  }
}

/**
 * Models a call to `thrd_join` in C11.
 */
class C11ThreadWait extends ThreadWait {
  VariableAccess var;

  C11ThreadWait() { getTarget().getName() = "thrd_join" }
}

/**
 * Models thread detach functions.
 */
abstract class ThreadDetach extends FunctionCall { }

/**
 * Models a call to `thrd_detach` in C11.
 */
class C11ThreadDetach extends ThreadWait {
  VariableAccess var;

  C11ThreadDetach() { getTarget().getName() = "thrd_detach" }
}

abstract class MutexSource extends FunctionCall { }

/**
 * Models a C++ style mutex.
 */
class CPPMutexSource extends MutexSource, ConstructorCall {
  CPPMutexSource() { getTarget().getDeclaringType().hasQualifiedName("std", "mutex") }
}

/**
 * Models a C11 style mutex.
 */
class C11MutexSource extends MutexSource, FunctionCall {
  C11MutexSource() { getTarget().hasName("mtx_init") }
}

/**
 * Models a thread dependent mutex. A thread dependent mutex is a mutex
 * that is used by a thread. This dependency is established either by directly
 * passing in a mutex or by referencing a mutex that is in the local scope. The utility
 * of this class is it captures the `DataFlow::Node` source at which the mutex
 * came from. For example, if it is passed in from a local function to a thread.
 * This functionality is critical, since it allows one to inspect how the thread
 * behaves with respect to the owner of a resource.
 *
 * To model the myriad ways this can happen, the subclasses of this class are
 * responsible for implementing the various usage patterns.
 */
abstract class ThreadDependentMutex extends DataFlow::Node {
  DataFlow::Node sink;

  DataFlow::Node getASource() {
    // the source is either the thing that declared
    // the mutex
    result = this
    or
    // or the thread we are using it in
    result = getAThreadSource()
  }

  /**
   * Gets the dataflow nodes corresponding to thread local usages of the
   * dependent mutex.
   */
  DataFlow::Node getAThreadSource() {
    // here we line up the actual parameter at the thread creation
    // site with the formal parameter in the target thread.
    // Note that there are differences between the C and C++ versions
    // of the argument ordering in the thread creation function. However,
    // since the C version only takes one parameter (as opposed to multiple)
    // we can simplify this search by considering only the first argument.
    exists(FunctionCall fc, Function f, int n |
      // Get the argument to which the mutex flowed.
      fc.getArgument(n) = sink.asExpr() and
      // Get the thread function we are calling.
      f = fc.getArgument(0).(FunctionAccess).getTarget() and
      // in C++, there is an extra argument to the `std::thread` call
      // so we must subtract 1 since this is not passed to the thread.
      (
        result = DataFlow::exprNode(f.getParameter(n - 1).getAnAccess())
        or
        // In C, only one argument is allowed. Thus IF the flow predicate holds,
        // it will be to the first argument
        result = DataFlow::exprNode(f.getParameter(0).getAnAccess())
      )
    )
  }

  /**
   * Produces the set of dataflow nodes to thread creation for threads
   * that are dependent on this mutex.
   */
  DataFlow::Node getADependentThreadCreationExpr() {
    exists(FunctionCall fc |
      fc.getAnArgument() = sink.asExpr() and
      result = DataFlow::exprNode(fc)
    )
  }

  /**
   * Gets a set of usages of this mutex in both the local and thread scope.
   * In the case of scoped usage, this also captures typical accesses of variables.
   */
  DataFlow::Node getAUsage() { TaintTracking::localTaint(getASource(), result) }
}

/**
 * This class models the type of thread/mutex dependency that is established
 * through the typical parameter passing mechanisms found in C++.
 */
class FlowBasedThreadDependentMutex extends ThreadDependentMutex {
  FlowBasedThreadDependentMutex() {
    // some sort of dataflow, likely through parameter passing.
    exists(ThreadDependentMutexTaintTrackingConfiguration config | config.hasFlow(this, sink))
  }
}

/**
 * This class models the type of thread/mutex dependency that is established by
 * either scope based accesses (e.g., global variables) or block scope differences.
 */
class AccessBasedThreadDependentMutex extends ThreadDependentMutex {
  Variable variableSource;

  AccessBasedThreadDependentMutex() {
    // encapsulates usages from outside scopes not directly expressed
    // in dataflow.
    exists(MutexSource mutexSrc, ThreadedFunction f |
      DataFlow::exprNode(mutexSrc) = this and
      // find a variable that was assigned the mutex
      TaintTracking::localTaint(DataFlow::exprNode(mutexSrc),
        DataFlow::exprNode(variableSource.getAnAssignedValue())) and
      // find all subsequent accesses of that variable that are within a
      // function and set those to the sink
      exists(VariableAccess va |
        va = variableSource.getAnAccess() and
        va.getEnclosingFunction() = f and
        sink = DataFlow::exprNode(va)
      )
    )
  }

  override DataFlow::Node getAUsage() { DataFlow::exprNode(variableSource.getAnAccess()) = result }
}

/**
 * In the typical C thread model, a mutex is a created by a function that is not responsible
 * for creating the variable. Thus this class encodes a slightly different semantics
 * wherein the usage pattern is that of variables that have been both initialized
 * and then subsequently passed into a thread directly.
 */
class DeclarationInitBasedThreadDependentMutex extends ThreadDependentMutex {
  Variable variableSource;

  DeclarationInitBasedThreadDependentMutex() {
    exists(MutexSource ms, ThreadCreationFunction tcf |
      this = DataFlow::exprNode(ms) and
      // accessed as a mutex source
      TaintTracking::localTaint(DataFlow::exprNode(variableSource.getAnAccess()),
        DataFlow::exprNode(ms.getAnArgument())) and
      // subsequently passed to a thread creation function (order not strictly
      // enforced for performance reasons)
      sink = DataFlow::exprNode(tcf.getAnArgument()) and
      TaintTracking::localTaint(DataFlow::exprNode(variableSource.getAnAccess()), sink)
    )
  }

  override DataFlow::Node getAUsage() {
    TaintTracking::localTaint(getASource(), result) or
    DataFlow::exprNode(variableSource.getAnAccess()) = result
  }

  override DataFlow::Node getASource() {
    // the source is either the thing that declared
    // the mutex
    result = this
    or
    // or the thread we are using it in
    result = getAThreadSource()
  }

  DataFlow::Node getSink() { result = sink }

  /**
   * Gets the dataflow nodes corresponding to thread local usages of the
   * dependent mutex.
   */
  override DataFlow::Node getAThreadSource() {
    // here we line up the actual parameter at the thread creation
    // site with the formal parameter in the target thread.
    // Note that there are differences between the C and C++ versions
    // of the argument ordering in the thread creation function. However,
    // since the C version only takes one parameter (as opposed to multiple)
    // we can simplify this search by considering only the first argument.
    exists(
      FunctionCall fc, Function f, int n // CPP Version
    |
      fc.getArgument(n) = sink.asExpr() and
      f = fc.getArgument(0).(FunctionAccess).getTarget() and
      // in C++, there is an extra argument to the `std::thread` call
      // so we must subtract 1 since this is not passed to the thread.
      result = DataFlow::exprNode(f.getParameter(n - 1).getAnAccess())
    )
    or
    exists(
      FunctionCall fc, Function f // C Version
    |
      fc.getAnArgument() = sink.asExpr() and
      // in C, the second argument is the function
      f = fc.getArgument(1).(FunctionAccess).getTarget() and
      // in C, the passed argument is always the zeroth argument
      result = DataFlow::exprNode(f.getParameter(0).getAnAccess())
    )
  }
}

/**
 * In the typical C model, another way to use mutexes is to work with global variables
 * that can be initialized at various points -- one of which must be inside a thread.
 * This class encapsulates this pattern.
 */
class DeclarationInitAccessBasedThreadDependentMutex extends ThreadDependentMutex {
  Variable variableSource;

  DeclarationInitAccessBasedThreadDependentMutex() {
    exists(MutexSource ms, ThreadedFunction tf, VariableAccess va |
      this = DataFlow::exprNode(ms) and
      // accessed as a mutex source
      TaintTracking::localTaint(DataFlow::exprNode(variableSource.getAnAccess()),
        DataFlow::exprNode(ms.getAnArgument())) and
      // is accessed somewhere else
      va = variableSource.getAnAccess() and
      sink = DataFlow::exprNode(va) and
      // one of which must be a thread
      va.getEnclosingFunction() = tf
    )
  }

  override DataFlow::Node getAUsage() { result = DataFlow::exprNode(variableSource.getAnAccess()) }
}

class ThreadDependentMutexTaintTrackingConfiguration extends TaintTracking::Configuration {
  ThreadDependentMutexTaintTrackingConfiguration() {
    this = "ThreadDependentMutexTaintTrackingConfiguration"
  }

  override predicate isSource(DataFlow::Node node) { node.asExpr() instanceof MutexSource }

  override predicate isSink(DataFlow::Node node) {
    exists(ThreadCreationFunction f | f.getAnArgument() = node.asExpr())
  }
}

/**
 * Models expressions that destroy mutexes.
 */
abstract class MutexDestroyer extends StmtParent {
  /**
   * Gets the expression that references the mutex being destroyed.
   */
  abstract Expr getMutexExpr();
}

/**
 * Models C style mutex destruction via `mtx_destroy`.
 */
class C11MutexDestroyer extends MutexDestroyer, FunctionCall {
  C11MutexDestroyer() { getTarget().getName() = "mtx_destroy" }

  /**
   * Returns the `Expr` being destroyed.
   */
  override Expr getMutexExpr() { result = getArgument(0) }
}

/**
 * Models a delete expression -- note it is necessary to add this in
 * addition to destructors to handle certain implementations of the
 * standard library which obscure the destructors of mutexes.
 */
class DeleteMutexDestroyer extends MutexDestroyer {
  DeleteMutexDestroyer() { this instanceof DeleteExpr }

  override Expr getMutexExpr() { this.(DeleteExpr).getExpr() = result }
}

/**
 * Models a possible mutex variable that if it goes
 * out of scope would destroy an underlying mutex.
 */
class LocalMutexDestroyer extends MutexDestroyer {
  Expr assignedValue;

  LocalMutexDestroyer() {
    exists(LocalVariable lv |
      // static types aren't destroyers
      not lv.isStatic() and
      // neither are pointers
      not lv.getType() instanceof PointerType and
      lv.getAnAssignedValue() = assignedValue and
      // map the location to the return statements of the
      // enclosing function
      exists(ReturnStmt rs |
        rs.getEnclosingFunction() = assignedValue.getEnclosingFunction() and
        rs = this
      )
    )
  }

  override Expr getMutexExpr() { result = assignedValue }
}

/**
 * Models implicit or explicit calls to the destructor of a mutex, either via
 * a `delete` statement or a variable going out of scope.
 */
class DestructorMutexDestroyer extends MutexDestroyer, DestructorCall {
  DestructorMutexDestroyer() { getTarget().getDeclaringType().hasQualifiedName("std", "mutex") }

  /**
   * Returns the `Expr` being deleted.
   */
  override Expr getMutexExpr() { getQualifier() = result }
}

/**
 * Models a conditional variable denoted by `std::condition_variable`.
 */
class ConditionalVariable extends Variable {
  ConditionalVariable() {
    getUnderlyingType().(Class).hasQualifiedName("std", "condition_variable")
  }
}

/**
 * Models a conditional function, which is a function that depends on the value
 * of a conditional variable.
 */
class ConditionalFunction extends Function {
  ConditionalFunction() {
    exists(ConditionalVariable cv | cv.getAnAccess().getEnclosingFunction() = this)
  }
}

/**
 * Models calls to thread specific storage function calls.
 */
abstract class ThreadSpecificStorageFunctionCall extends FunctionCall {
  /**
   * Gets the key to which this call references.
   */
  Expr getKey() { getArgument(0) = result }
}

/**
 * Models calls to `tss_get`.
 */
class TSSGetFunctionCall extends ThreadSpecificStorageFunctionCall {
  TSSGetFunctionCall() { getTarget().getName() = "tss_get" }
}

/**
 * Models calls to `tss_set`.
 */
class TSSSetFunctionCall extends ThreadSpecificStorageFunctionCall {
  TSSSetFunctionCall() { getTarget().getName() = "tss_set" }
}

/**
 * Models calls to `tss_create`
 */
class TSSCreateFunctionCall extends ThreadSpecificStorageFunctionCall {
  TSSCreateFunctionCall() { getTarget().getName() = "tss_create" }

  predicate hasDeallocator() {
    not exists(MacroInvocation mi, NullMacro nm |
      getArgument(1) = mi.getExpr() and
      mi = nm.getAnInvocation()
    )
  }
}

/**
 * Models calls to `tss_delete`
 */
class TSSDeleteFunctionCall extends ThreadSpecificStorageFunctionCall {
  TSSDeleteFunctionCall() { getTarget().getName() = "tss_delete" }
}

/**
 * Gets a call to `DeallocationExpr` that deallocates memory owned by thread specific
 * storage.
 */
predicate getAThreadSpecificStorageDeallocationCall(C11ThreadCreateCall tcc, DeallocationExpr dexp) {
  exists(TSSGetFunctionCall tsg |
    tcc.getFunction().getEntryPoint().getASuccessor*() = tsg and
    DataFlow::localFlow(DataFlow::exprNode(tsg), DataFlow::exprNode(dexp.getFreedExpr()))
  )
}

/**
 * Models calls to routines `atomic_compare_exchange_weak` and
 * `atomic_compare_exchange_weak_explicit` in the `stdatomic` library.
 * Note that these are typically implemented as macros within Clang and
 * GCC's standard libraries.
 */
class AtomicCompareExchange extends MacroInvocation {
  AtomicCompareExchange() {
    getMacroName() = "atomic_compare_exchange_weak"
    or
    // some compilers model `atomic_compare_exchange_weak` as a macro that
    // expands to `atomic_compare_exchange_weak_explicit` so this defeats that
    // and other similar modeling.
    getMacroName() = "atomic_compare_exchange_weak_explicit" and
    not exists(MacroInvocation m |
      m.getMacroName() = "atomic_compare_exchange_weak" and
      m.getAnExpandedElement() = getAnExpandedElement()
    )
  }
}

/**
 * Models calls to routines `atomic_store` and
 * `atomic_store_explicit` in the `stdatomic` library.
 * Note that these are typically implemented as macros within Clang and
 * GCC's standard libraries.
 */
class AtomicStore extends MacroInvocation {
  AtomicStore() {
    getMacroName() = "atomic_store"
    or
    // some compilers model `atomic_compare_exchange_weak` as a macro that
    // expands to `atomic_compare_exchange_weak_explicit` so this defeats that
    // and other similar modeling.
    getMacroName() = "atomic_store_explicit" and
    not exists(MacroInvocation m |
      m.getMacroName() = "atomic_store" and
      m.getAnExpandedElement() = getAnExpandedElement()
    )
  }
}
