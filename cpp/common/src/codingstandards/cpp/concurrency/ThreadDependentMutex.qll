import cpp
import semmle.code.cpp.dataflow.TaintTracking
private import codingstandards.cpp.concurrency.ControlFlow
private import codingstandards.cpp.concurrency.ThreadedFunction

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

  Expr getMutexExpr() { result = getArgument(0) }

  Expr getMutexTypeExpr() { result = getArgument(1) }

  predicate isRecursive() {
    exists(EnumConstantAccess recursive |
      recursive = getMutexTypeExpr().getAChild*() and
      recursive.getTarget().hasName("mtx_recursive")
    )
  }
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
    ThreadDependentMutexFlow::flow(this, sink)
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

module ThreadDependentMutexConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) { node.asExpr() instanceof MutexSource }

  predicate isSink(DataFlow::Node node) {
    exists(ThreadCreationFunction f | f.getAnArgument() = node.asExpr())
  }
}

module ThreadDependentMutexFlow = TaintTracking::Global<ThreadDependentMutexConfig>;
