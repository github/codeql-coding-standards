/**
 * A module containing a representation of the graph of dependencies for the initialization of
 * static storage duration objects.
 *
 * This static initialization graph is determined by identifying static storage duration variables
 * in the program, then tracing from the initializer of those variables to all the functions and
 * variables which are called or initialized in that process.
 *
 * In practice, the graph is made up of four types of node:
 *  - `InitializerNode` - a variable intializer that is called during static initialization.
 *  - `FunctionNode` - a function that is called during static initialization.
 *  - `FunctionCallNode` - a function call that occurs during static initialization.
 *  - `VariableAccessNode` - a variable access that occurs during static initialization.
 *
 * Note: this module is about initialization of static storage duration objects, not just variables
 * marked with the keyword `static`.
 */

import cpp

module StaticInitializationGraph {
  /*
   * The strategy for this module is to:
   *  - Create a `TNode` `newtype` that includes injectors for each of the node types
   *  - Use the injectors to restrict the nodes to only those which are reachable from a static
   *    duration object initializer.
   *  - Create a `Node` instance for each injector type.
   */

  /**
   * Gets an Expr directly or indirectly included in an initializer.
   */
  private Expr getAnInitializerExpr(Initializer i) {
    result = i.getExpr()
    or
    result = getAnInitializerExpr(i).getAChild()
  }

  newtype TNode =
    TInitializerNode(Initializer i) {
      // This is the initializer of a static storage duration variable
      exists(StaticStorageDurationVariable v | v.getInitializer() = i)
      or
      // This is the initializer of a variable that is accessed during static initialization
      exists(
        TVariableAccessNode(any(VariableAccess va |
            va.getTarget().getInitializer() = i and
            // Ignore varaccess which just take the address, as that does not trigger static
            // initialization of target
            not va.isAddressOfAccess()
          ))
      )
    } or
    TFunctionNode(Function f) {
      // This is a function that is called during static initialization
      exists(TFunctionCallNode(any(FunctionCall fc | fc.getTarget() = f)))
    } or
    TFunctionCallNode(FunctionCall fc) {
      // This is a function call that occurs in an initializer called during static initialization
      exists(TInitializerNode(any(Initializer i | getAnInitializerExpr(i) = fc)))
      or
      // This is a function call that occurs in a function called during static initialization
      exists(
        TFunctionNode(any(Function f |
            f = fc.getEnclosingFunction() and
            // Not in an initializer of a local variable, where the desired flow is instead:
            // function -> initializer -> fc
            not exists(Initializer i | getAnInitializerExpr(i) = fc)
          ))
      )
    } or
    TVariableAccessNode(VariableAccess va) {
      // This is a variable that is accessed in an initializer called during static initialization
      exists(TInitializerNode(any(Initializer i | getAnInitializerExpr(i) = va)))
      or
      // This is a variable that is accessed in a function called during static initialization
      exists(
        TFunctionNode(any(Function f |
            f = va.getEnclosingFunction() and
            // Not in an initializer of a local variable, where the desired flow is instead:
            // function -> initializer -> va
            not exists(Initializer i | getAnInitializerExpr(i) = va)
          ))
      )
    }

  /**
   * A node in the graph of dependencies for the initialization of static storage duration objects.
   */
  class Node extends TNode {
    /** Gets a textual representation of this element. */
    string toString() { none() } // overridden by subclasses

    /** Gets the location of this element. */
    Location getLocation() { none() } // overridden by subclasses

    /** Gets the `Expr` for this node, if any. */
    Expr getExpr() { none() } // overridden by subclasses
  }

  /**
   * An initializer which is called during static initialization.
   */
  class InitializerNode extends TInitializerNode, Node {
    Initializer getInitializer() { this = TInitializerNode(result) }

    override Location getLocation() { result = getInitializer().getLocation() }

    override string toString() { result = getInitializer().toString() }
  }

  /**
   * A function which is called during static initialization.
   */
  class FunctionNode extends TFunctionNode, Node {
    Function getFunction() { this = TFunctionNode(result) }

    override Location getLocation() { result = getFunction().getLocation() }

    override string toString() { result = getFunction().toString() }
  }

  /**
   * A function call which occurs during static initialization.
   */
  class FunctionCallNode extends TFunctionCallNode, Node {
    FunctionCall getFunctionCall() { this = TFunctionCallNode(result) }

    override Location getLocation() { result = getFunctionCall().getLocation() }

    override string toString() { result = getFunctionCall().toString() }

    override Expr getExpr() { result = getFunctionCall() }
  }

  /**
   * A variable access which occurs during static initialization.
   */
  class VariableAccessNode extends TVariableAccessNode, Node {
    VariableAccess getVariableAccess() { this = TVariableAccessNode(result) }

    override Location getLocation() { result = getVariableAccess().getLocation() }

    override string toString() { result = getVariableAccess().toString() }

    override Expr getExpr() { result = getVariableAccess() }
  }

  /**
   * Holds if there is a potential static initialization step between `n1` and `n2`.
   */
  predicate step(Node n1, Node n2) {
    // VarAccess to Initializer step
    n1.(VariableAccessNode).getVariableAccess().getTarget().getInitializer() =
      n2.(InitializerNode).getInitializer() and
    // Ignore accesses which take the address, as that does not trigger initialization
    not n1.(VariableAccessNode).getVariableAccess().isAddressOfAccess()
    or
    // Initializer steps
    exists(Initializer i | i = n1.(InitializerNode).getInitializer() |
      getAnInitializerExpr(i) = n2.getExpr()
    )
    or
    // FunctionCall steps
    n1.(FunctionCallNode).getFunctionCall().getTarget() = n2.(FunctionNode).getFunction() and
    // Workaround an extractor bug whereby we generate spurious destructor calls for static local variables
    not exists(LocalVariable v |
      v.isStatic() and
      n1.(FunctionCallNode).getFunctionCall().getQualifier() = v.getAnAccess() and
      n2.(FunctionNode).getFunction() instanceof Destructor
    )
    or
    // Function step
    exists(Function f | f = n1.(FunctionNode).getFunction() |
      // Node is an expression whose enclosing function is `f`
      f = n2.getExpr().getEnclosingFunction() and
      // But not in an initializer of a local variable, where the desired flow is instead:
      // function -> initializer -> expression
      not exists(Initializer i | getAnInitializerExpr(i) = n2.getExpr())
      or
      // `n2` is an initializer of a local scope variable within function `f`
      n2.(InitializerNode).getInitializer().getDeclaration().(LocalScopeVariable).getFunction() = f
    )
  }

  /**
   * Gets a `Node` which is reachable during static initialization of the variable `v`.
   */
  Node getAReachableNode(StaticStorageDurationVariable v) {
    exists(InitializerNode i | i.getInitializer() = v.getInitializer() | step*(i, result))
  }
}
