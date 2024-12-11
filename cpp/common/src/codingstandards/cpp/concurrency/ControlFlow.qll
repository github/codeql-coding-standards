import cpp
private import codingstandards.cpp.concurrency.ThreadedFunction

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
