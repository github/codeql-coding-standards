/**
 * A module for creating custom path problem results in CodeQL from a stateful graph search.
 *
 * This module will soon be moved to a shared library outside of this project.
 */

import cpp
import codingstandards.cpp.graph.GraphPathStateSearch as Search

/**
 * To create a custom stateful path problem, simply define the `Node` you want to search (which
 * must be `Locatable`) and the `State` class for your path search state. Then, implement the
 * `edge` relation, and `start` and `end` predicates to indicate the types of things that should
 * be considered problems when connected in the graph.
 *
 * Optionally, you can also implement the `edgeInfo` and `nodeLabel` predicates to provide
 * additional information about the edges and nodes in the graph.
 *
 * Lastly, import `CustomPathStateProblem<YourConfig>` to get the `problem` predicate, which holds for
 * pairs of connected locations that will be traceable in the path problem results.
 *
 * See the `CallGraphPathStateProblemConfig` module for an example of how to use this module.
 */
signature module CustomPathStateProblemConfigSig {
  /**
   * A class that connects nodes in the graph to search locations.
   *
   * This class should be as small as possible, to avoid unnecessary search space.
   */
  class Node extends Element;

  /**
   * A class that represents the state of the path search.
   *
   * This is initialized in `start()` and checked in `end()`. It also may be forwarded and/or
   * transformed in the `edge()` predicate.
   */
  bindingset[this]
  class State;

  /**
   * The directional edges of the graph, from `a` to `b`, and how the state progresses from `s1`
   * to `s2` at this edge.
   *
   * The design of this predicate will have a large impact on the performance of the search.
   * However, the underlying search algorithm is efficient, so this should be fast in many cases
   * even if this is a very large relation.
   */
  bindingset[s1]
  bindingset[s2]
  predicate edge(Node a, State s1, Node b, State s2);

  /**
   * Optional predicate to set additional information on the edges of the graph.
   *
   * By setting `key` to "provenance", the `val` string will be displayed in the path problem
   * results, with one line per word in `val`.
   */
  bindingset[a, b]
  default predicate edgeInfo(Node a, Node b, string key, string val) { key = "" and val = "" }

  /**
   * Optional predicate to set a label on the nodes of the graph.
   *
   * This does not appear to be used by vscode when displaying path problem results, but it is
   * still part of the path problem API.
   */
  bindingset[n]
  default predicate nodeLabel(Node n, string value) { value = n.toString() }

  /**
   * Where the graph search should start with a given initial state.
   *
   * If this node is connected to a node `x` that holds for `end(x)`, then `problem(n, x)` will hold
   * and edges between them will be added to the path problem results.
   */
  predicate start(Node n, State s);

  /**
   * Where the graph search should end (an end node and an end state).
   *
   * If this node is connected to a node `x` that holds for `start(x)`, then `problem(x, n)` will hold
   * and edges between them will be added to the path problem results.
   */
  bindingset[s]
  predicate end(Node n, State s);

  /**
   * Whether the graph search should continue past the end nodes.
   */
  default predicate searchPastEnd() { any() }
}

/**
 * A module for creating custom path problem results in CodeQL, using an efficient forward-reverse
 * search pattern under the hood with state tracked along the edges.
 *
 * Implement `CustomPathStateProblemConfigSig` to define the nodes and edges of your graph, as well as
 * start and end predicates to indicate the types of things that should be considered problems
 * when connected in the graph.
 *
 * Then import this module, and select nodes for which `problem(a, b)` holds, and they will be
 * traceable in the path problem results.
 *
 * Example usage:
 * ```ql
 * module MacroPathProblemConfig implements CustomPathProblemConfigSig {
 *   class Node extends Locatable {
 *     Node() { this instanceof Macro or this instanceof MacroInvocation }
 *   }
 *
 *   class State = int; // Set a max search depth
 *
 *   predicate start(Node n, State depth) {
 *     // Start at root macro invocations
 *     n instanceof MacroInvocation and not exists(n.(MacroInvocation).getParentInvocation()) and
 *     // Set the initial state to a depth of 0
 *     depth = 0
 *   }
 *
 *   // Find calls to macros we don't like, at any depth
 *   predicate end(Node n, State depth) { n instanceof Macro and isBad(n) and depth = any() }
 *
 *   predicate edge(Node a, State s1, Node b, State s2) {
 *     // Limit the search depth to 10
 *     s1 < 10 and
 *     // Increment the state which represents the search depth
 *     s2 = s1 + 1 and
 *     (
 *       // The root macro invocation is connected to its definition
 *       b = a.(MacroInvocation).getMacro()
 *       or
 *       exists(MacroInvocation inner, MacroInvocation next |
 *          // Connect inner macros to the macros that invoke them
 *          inner.getParentInvocation() = next() and
 *          a = inner.getMacro() and b = next.getMacro()
 *       )
 *     )
 *   }
 * }
 *
 * // Import query predicates that make path-problem work correctly
 * import CustomPathStateProblem<MacroPathProblemConfig>
 *
 * from MacroInvocation start, Macro end
 * where problem(start, end) // find macro invocations that are connected to bad macros
 * select start, start, end, "Macro invocation eventually calls a macro we don't like: $@", end, end.getName()
 * ```
 *
 * There is also a predicate `problem(a, s1, b, s2)` for reporting problems with their stateful
 * search results.
 */
module CustomPathStateProblem<CustomPathStateProblemConfigSig Config> {
  private module ForwardReverseConfig implements Search::GraphPathStateSearchSig<Config::Node> {
    predicate edge = Config::edge/4;

    predicate start = Config::start/2;

    predicate end = Config::end/2;

    class State = Config::State;

    predicate searchPastEnd = Config::searchPastEnd/0;
  }

  private import Search::GraphPathStateSearch<Config::Node, ForwardReverseConfig> as SearchResults

  /** The magical `edges` query predicate that powers `@kind path-problem` along with `nodes`. */
  query predicate edges(Locatable a, Locatable b, string key, string val) {
    SearchResults::pathEdge(a, b) and
    Config::edgeInfo(a, b, key, val)
  }

  /** The magical `nodes` query predicate that powers `@kind path-problem` along with `edges`. */
  query predicate nodes(Config::Node n, string key, string value) {
    n instanceof SearchResults::ReverseNode and
    // It seems like "semmle.label" is the only valid key.
    key = "semmle.label" and
    Config::nodeLabel(n, value)
  }

  /**
   * A predicate that holds for locations that are connected in the graph.
   *
   * These pairs should all be problems reported by the query, otherwise the search space is larger
   * than necessary.
   */
  predicate problem(Config::Node a, Config::Node b) { SearchResults::hasConnection(a, b) }

  /**
   * A predicate that holds for locations that are connected in the graph.
   *
   * These pairs should all be problems reported by the query, otherwise the search space is larger
   * than necessary.
   */
  predicate problem(Config::Node a, Config::State s1, Config::Node b, Config::State s2) {
    SearchResults::hasConnection(a, s1, b, s2)
  }
}
