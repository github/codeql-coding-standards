import cpp

/**
 * The configuration signature for the FeasiblePath module.
 *
 * Typically, the `Node` type should be a `ControlFlowNode`, but it can be overridden to enable
 * other kinds of graphs.
 */
signature module FeasiblePathConfigSig {
  /** The state type used to carry context through the CFG exploration. */
  class State;

  /** The node type used to represent CFG nodes. Overridable. */
  class Node {
    Node getASuccessor();
  }

  predicate isStart(State state, Node node);

  predicate isExcludedPath(State state, Node node);

  predicate isEnd(State state, Node node);
}

/**
 * A module that finds whether a feasible path exists between two control flow nodes, and
 * additionally support configuration that should not be traversed.
 *
 * Also accepts a state parameter to allow a context to flow through the CFG.
 *
 * ## Usage
 *
 * Implement the module `ConfigSig`, with some context type:
 *
 * ```ql
 * module MyConfig implements FeasiblePathConfigSig {
 *   predicate isStart(SomeContext state, ControlFlowNode node) {
 *     node = state.someStartCondition()
 *   }
 *
 *   predicate isExcludedPath(SomeContext state, ControlFlowNode node) {
 *    node = state.someExcludedPathCondition()
 *   }
 *
 *   predicate isEnd(SomeContext state, ControlFlowNode node) {
 *     node = state.someEndCondition()
 *   }
 * }
 *
 * import FeasiblePath<MyConfig> as MyFeasiblePath
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
 *     isExcludedPath(mid)
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
 *   excluded();
 * }
 * ```
 *
 * In the above code, `excluded()` is a successor of `start()`, and `end()` is also a successor of
 * `excluded()` (via the loop back edge). However, there is no path from `start()` to `end()` that
 * does not pass through `excluded()`.
 *
 * This module will correctly handle this case. Forward exploration through the graph will stop
 * at the `excluded()` nodes, such that only paths from `start()` to `end()` that do not pass
 * through `excluded()` nodes will be found.
 */
module FeasiblePath<FeasiblePathConfigSig Config> {
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
        not Config::isExcludedPath(state, mid) and
        not Config::isEnd(state, prevMid)
      )
    )
  }
}
