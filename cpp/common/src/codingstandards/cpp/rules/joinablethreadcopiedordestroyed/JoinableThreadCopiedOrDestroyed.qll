/**
 * Provides a library which includes a `problems` predicate for reporting joinable threads that are
 * copied or destroyed.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.standardlibrary.Threads
import codingstandards.cpp.standardlibrary.Utility
import semmle.code.cpp.controlflow.StackVariableReachability

abstract class JoinableThreadCopiedOrDestroyedSharedQuery extends Query { }

Query getQuery() { result instanceof JoinableThreadCopiedOrDestroyedSharedQuery }

/*
 * Note: This query uses a simple approach based on `StackVariableReachability` to track the
 *       joinable state of local scope variables of type `std::thread`. As such, it only supports
 *       intra-procedural analysis within a single function. It is also limited in its ability to
 *       track state across `swap` or `move` calls.
 *
 *       An improved query is possible using data flow, but requires careful modeling of join calls.
 *
 * Note: This query also does not support thread arrays.
 */

/**
 * A stack variable reachability class for finding thread objects which may be joinable when destroyed
 * or assigned over.
 */
class JoinableThreads extends StackVariableReachability {
  JoinableThreads() { this = "JoinableThreads" }

  override predicate isSource(ControlFlowNode node, StackVariable v) {
    v.getType() instanceof StdThread and
    // Must be a non-default initialized std::thread, otherwise not joinable
    node =
      any(ConstructorCall cc | cc = v.getInitializer().getExpr() and cc.getNumberOfArguments() > 0)
  }

  override predicate isSink(ControlFlowNode node, StackVariable v) {
    // The thread is destroyed
    node.(StdThreadDestructorCall).getQualifier() = v.getAnAccess()
    or
    // A move assignment overwrites the existing thread for this variable
    v.getAnAccess() = node.(StdThreadMoveAssignmentCall).getQualifier()
  }

  override predicate isBarrier(ControlFlowNode node, StackVariable v) {
    node.(StdThreadJoinCall).getQualifier() = v.getAnAccess()
    or
    // A call to std::move in a move-assignment call
    node.(StdThreadMoveAssignmentCall).getArgument(0).(StdMoveCall).getArgument(0) = v.getAnAccess()
    or
    // After std::thread::detach, the std::thread object is no longer joinable
    node.(StdThreadDetachCall).getQualifier() = v.getAnAccess()
  }
}

query predicate problems(ControlFlowNode sink, string message) {
  not isExcluded(sink, getQuery()) and
  exists(JoinableThreads joinableThreads, ControlFlowNode source, string description |
    joinableThreads.reaches(source, _, sink) and
    (
      sink instanceof StdThreadDestructorCall and description = "destroyed"
      or
      sink instanceof StdThreadMoveAssignmentCall and description = "move-assigned"
    ) and
    message = "A std::thread object which has not yet been joined is " + description + " here."
  )
}
