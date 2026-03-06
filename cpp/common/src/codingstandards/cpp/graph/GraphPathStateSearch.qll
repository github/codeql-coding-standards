/**
 * This module will soon be moved to a shared library outside of this project.
 *
 * Like `GraphPathSearch`, this file defines a module for efficiently finding paths in a directional
 * graph using a performant pattern called forward-reverse pruning.
 *
 * Additionally, this module is designed to track state through the paths it is looking for. For
 * instance, we could use this graph to find recursive functions, which requires knowing how an end
 * node was reached from a start node (the state).
 *
 * Like `GraphPathSearch`, this module uses forward-reverse pruning, which is a pattern that is
 * useful for efficiently finding connections between nodes in a directional graph. In a first pass,
 * it finds nodes reachable from the starting point. In the second pass, it finds the subset of
 * those nodes that can be reached from the end point. Together, these create a path from start
 * points to end points.
 *
 * As with the other performance patterns in qtil, this module may be useful as is, or it may not
 * fit your needs exactly. CodeQL evaluation and performance is very complex. In that case, consider
 * this pattern as an example to create your own solution that fits your needs.
 */
signature class FiniteType;

/**
 * Implement this signature to define a graph, and a search for paths within that graph tracking
 * some state, using the `GraphPathStateSearch` module.
 *
 * ```ql
 * module MyConfig implements GraphPathStateSearchSig<Node> {
 *   class State extends ... { ... };
 *   predicate start(Node n1) { ... }
 *   predicate edge(Node n1, Node n2) { ... }
 *   predicate end(Node n1) { ... }
 * }
 * ```
 *
 * To flow without state, use `GraphPathSearchSig` instead.
 */
signature module GraphPathStateSearchSig<FiniteType Node> {
  /**
   * The state to be tracked through the paths found by this module.
   *
   * For example, if searching for recursive functions, this class might be defined as:
   *
   * ```ql
   * class State = Function;
   * ```
   *
   * The `edges` predicate defined in this signature module decides how to forward this state, so
   * the state may change as the path is traversed.
   */
  bindingset[this]
  class State;

  /**
   * The nodes that begin the search of the graph, and the starting state for those nodes.
   *
   * For instance, if searching for recursive functions, this predicate might hold for a Function
   * and its state may be the Function itself.
   *
   * Ultimately, only paths from a start node to an end node will be found by this module.
   *
   * In most cases, this will ideally be a smaller set of nodes than the end nodes. However, if the
   * graph branches in one direction more than the other, a larger set which branches less may be
   * preferable.
   *
   * The design of this predicate has a great effect in how well this performance pattern will
   * ultimately perform.
   */
  predicate start(Node n1, State s1);

  /**
   * A directional edge from `n1` to `n2`, and the state that is forwarded from `n1` to `n2`.
   *
   * This module will search for paths from `start` to `end` by looking following the direction of
   * these edges.
   *
   * As an example state transformation, a maximum search depth could be tracked at each edge and
   * the new state would be the old state with the depth incremented by one. Alternatively, if
   * searching for recursive functions, the state could be the starting function, and this edge
   * relation would forward that function unchanged.
   *
   * The design of this predicate has a great effect in how well this performance pattern will
   * ultimately perform.
   */
  bindingset[s1]
  bindingset[s2]
  predicate edge(Node n1, State s1, Node n2, State s2);

  /**
   * The end nodes of the search, if reached with the given state.
   *
   * For instance, if searching for recursive functions, this predicate would likely hold when a
   * function node is reached with the state being same function declaration (indicating flow from
   * the start function to itself).
   *
   * Ultimately, only paths from a start node to an end node will be found by this module.
   *
   * The design of this predicate has a great effect in how well this performance pattern will
   * ultimately perform.
   */
  bindingset[s1]
  predicate end(Node n1, State s1);

  /**
   * Whether the search should continue past the end nodes.
   */
  default predicate searchPastEnd() { any() }
}

/**
 * A module that implements an efficient search for a path that satisfies specified stateful
 * constraints within a custom directional graph from a set of start nodes to a set of end nodes.
 *
 * For example, this module can be used to detect loops in the graph (perhaps to find recursive
 * functions) by setting the "state" to be the start node, forwarding that state unchanged on each
 * edge, and considering a node to be an end node if it is reached with itself as the state.
 * Alternatively, the state could be used to track a maximum search depth, with a start state of
 * zero that is incremented at each edge, and where the edge relation does not hold beyond a certain
 * depth.
 *
 * To show discovered paths to users, see the module `CustomPathStateProblem` which uses this module
 * as * its underlying search implementation.
 *
 * This module uses a pattern called "forward reverse pruning" for efficiency. This pattern is
 * useful for reducing the search space when looking for paths in a directional graph. In a first
 * pass, it finds nodes reachable from the starting point. In the second pass, it finds the subset
 * of those nodes that can be reached from the end point. Together, these create a path from start
 * points to end points.
 *
 * To use this module, provide an implementation of the `GraphPathSearchSig` signature as follows:
 *
 * ```ql
 * module Config implements GraphPathSearchSig<Person> {
 *   class State extends Something { ... };
 *   predicate start(Person p, State s) { p.checkSomething() and s = p.getSomeStartValue() }
 *   predicate edge(Person p1, State s1, Person p2, State s2) { p2 = p1.getAParent() and s2 = s1.next() }
 *   predicate end(Person p, State s) { p.checkSomethingElse() and s.isValidEndState() }
 * }
 * ```
 *
 * The design of these predicate has a great effect in how well this performance pattern will
 * ultimately perform.
 *
 * The resulting predicate `hasPath` should be a much more efficient search of connected start nodes
 * to end nodes than a naive search (which in CodeQL could easily be evaluated as either a full
 * graph search, or a search over the cross product of all nodes).
 *
 * ```ql
 * from Person p1, State s1, Person p2, State s2
 * // Fast graph path detection thanks to forward-reverse pruning.
 * where GraphPathStateSearch<Person, Config>::hasPath(p1, s1, p2, p2)
 * select p1, s1, p2, p2
 * ```
 *
 * The resulting module also exposes two predicates:
 * - `ForwardNode`: All nodes reachable from the start nodes, with member predicate `getState()`.
 * - `ReverseNode`: All forward nodes that reach end nodes, with member predicate `getState()`.
 *
 * These classes may be useful in addition to the `hasPath` predicate.
 *
 * To track state as well as flow, use `GraphPathStateSearch` instead.
 */
module GraphPathStateSearch<FiniteType Node, GraphPathStateSearchSig<Node> Config> {
  final private class FinalNode = Node;

  /**
   * The set of all nodes reachable from the start nodes (inclusive).
   *
   * Includes the member predicate `getState()` which returns the state associated with this node at
   * this point in the search.
   */
  class ForwardNode extends FinalNode {
    Config::State state;

    ForwardNode() { forwardNode(this, state) }

    /**
     * Get the state associated with this forward node at this point in the search.
     */
    Config::State getState() { result = state }

    string toString() { result = "ForwardNode" }
  }

  /**
   * The performant predicate for looking forward one step at a time in the graph.
   *
   * In `GraphPathSearch`, this is fast because it is essentially a unary predicate. The same is
   * true here when the correct joins occur, such that (n, s) effectively act as a single value.
   *
   * For this reason, we use `pragma[only_bind_into]` to ensure the correct join order.
   */
  private predicate forwardNode(Node n, Config::State s) {
    Config::start(pragma[only_bind_into](n), pragma[only_bind_into](s))
    or
    exists(Node n0, Config::State s0 |
      forwardNode(pragma[only_bind_into](n0), pragma[only_bind_into](s0)) and
      Config::edge(n0, s0, pragma[only_bind_into](n), pragma[only_bind_into](s)) and
      (Config::end(n0, s0) implies Config::searchPastEnd())
    )
  }

  /**
   * The set of all forward nodes that reach end nodes (inclusive).
   *
   * Includes the member predicate `getState()` which returns the state associated with this node at
   * this point in the search.
   *
   * These nodes are the nodes that exist along the path from start nodes to end nodes.
   *
   * Note: this is fast to compute because it is essentially a unary predicate.
   */
  class ReverseNode extends ForwardNode {
    ReverseNode() {
      // 'state' field and getState() predicate are inherited from ForwardNode
      reverseNode(this, state)
    }

    override string toString() { result = "ReverseNode" }
  }

  private predicate reverseNode(Node n, Config::State s) {
    forwardNode(pragma[only_bind_into](n), pragma[only_bind_into](s)) and
    Config::end(n, s)
    or
    exists(Node n0, Config::State s0 |
      reverseNode(pragma[only_bind_into](n0), pragma[only_bind_into](s0)) and
      Config::edge(n, s, n0, s0)
    )
  }

  /**
   * A start node, end node pair that are connected in the graph.
   */
  predicate hasConnection(ReverseNode n1, ReverseNode n2) { hasConnection(n1, _, n2, _) }

  /**
   * A start node, end node pair that are connected in the graph, and the states associated with
   * those nodes.
   */
  predicate hasConnection(ReverseNode n1, Config::State s1, ReverseNode n2, Config::State s2) {
    Config::start(n1, s1) and
    Config::end(n2, s2) and
    (
      hasPath(n1, s1, n2, s2)
      or
      n1 = n2 and s1 = s2
    )
  }

  /**
   * All relevant edges in the graph which participate in a connection from a start to an end node.
   */
  predicate pathEdge(ReverseNode n1, ReverseNode n2) { pathEdge(n1, _, n2, _) }

  /**
   * All relevant edges in the graph, plus state, which participate in a connection from a start to
   * an end node.
   */
  predicate pathEdge(ReverseNode n1, Config::State s1, ReverseNode n2, Config::State s2) {
    Config::edge(n1, s1, n2, s2) and
    reverseNode(pragma[only_bind_into](n2), pragma[only_bind_into](s2))
  }

  /**
   * A performant path search within a custom directed graph from a set of start nodes to a set of
   * end nodes.
   *
   * This predicate is the main entry point for the forward-reverse pruning pattern. The design of
   * the config predicates has a great effect in how well this performance pattern will ultimately
   * perform.
   *
   * Example:
   * ```ql
   * from Person p1, Person p2
   * where GraphPathSearch<Person, Config>::hasPath(p1, p2)
   * select p1, p2
   * ```
   *
   * Note: this is fast to compute because limits the search space to nodes found by the fast unary
   * searches done to find `ForwardNode` and `ReverseNode`.
   */
  predicate hasPath(ReverseNode n1, Config::State s1, ReverseNode n2, Config::State s2) {
    Config::start(n1, s1) and
    Config::edge(n1, s1, n2, s2)
    or
    exists(ReverseNode nMid, Config::State sMid |
      hasPath(n1, s1, nMid, sMid) and
      Config::edge(pragma[only_bind_out](nMid), pragma[only_bind_out](sMid), n2, s2)
    )
  }
}
