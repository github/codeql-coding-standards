import cpp

/**
 * The configuration signature for the SuccessorUnless module.
 *
 * Typically, the `Node` type should be a `ControlFlowNode`, but it can be overridden to enable
 * other kinds of graphs.
 */
signature module SuccessorUnlessConfigSig {
  /** The state type used to carry context through the CFG exploration. */
  class State;

  /** The node type used to represent CFG nodes. Overridable. */
  class Node {
    Node getASuccessor();
  }

  predicate isStart(State state, Node node);

  predicate isUnless(State state, Node node);

  predicate isEnd(State state, Node node);
}

/**
 * A module that finds successor of a node -- unless there is an intermediate node that satisfies
 * a given condition.
 *
 * Also accepts a state parameter to allow a context to flow through the CFG.
 *
 * ## Usage
 *
 * Implement the module `ConfigSig`, with some context type:
 *
 * ```ql
 * module MyConfig implements SuccessorUnless<SomeContext>::ConfigSig {
 *   predicate isStart(SomeContext state, ControlFlowNode node) {
 *     node = state.someStartCondition()
 *   }
 *
 *   predicate isUnless(SomeContext state, ControlFlowNode node) {
 *    node = state.someUnlessCondition()
 *   }
 *
 *   predicate isEnd(SomeContext state, ControlFlowNode node) {
 *     node = state.someEndCondition()
 *   }
 * }
 *
 * import SuccessorUnless<SomeContext>::Make<MyConfig> as Successor
 * ```
 *
 * ## Rationale
 *
 * Why does this module exist? While it may be tempting to write:
 *
 * ```ql
 * exists(ControlFlowNode start, ControlFlowNode end) {
 *   isStart(start) and
 *   isEnd(end) and
 *   end = start.getASuccessor*() and
 *   not exists(ControlFlowNode mid |
 *     mid = start.getASuccessor+() and
 *     end = mid.getASuccessor*() and
 *     isUnless(mid)
 *   )
 * }
 * ```
 *
 * This has an unintuitive trap case in looping CFGs:
 *
 * ```c
 * while (cond) {
 *   start();
 *   end();
 *   unless();
 * }
 * ```
 *
 * In the above code, `unless()` is a successor of `start()`, and `end()` is also a successor of
 * `unless()` (via the loop back edge). However, there is no path from `start()` to `end()` that
 * does not pass through `unless()`.
 *
 * This module will correctly handle this case. Forward exploration through the graph will stop
 * at the `unless()` nodes, such that only paths from `start()` to `end()` that do not pass through
 * `unless()` nodes will be found.
 */
module SuccessorUnless<SuccessorUnlessConfigSig Config> {
  predicate isSuccessor(Config::State state, Config::Node start, Config::Node end) {
    isMid(state, start, end) and
    Config::isEnd(state, end)
  }

  private predicate isMid(Config::State state, Config::Node start, Config::Node mid) {
    // TODO: Explore if forward-reverse pruning would be beneficial for performance here.
    Config::isStart(state, start) and
    (
      mid = start
      or
      exists(Config::Node prevMid |
        isMid(state, start, prevMid) and
        mid = prevMid.getASuccessor() and
        not Config::isUnless(state, mid) and
        not Config::isEnd(state, prevMid)
      )
    )
  }
}
