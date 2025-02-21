import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.valuenumbering.HashCons
import semmle.code.cpp.controlflow.Dominance
import codeql.util.Boolean

/**
 * A library for detecting leaked resources.
 *
 * To use this library, implement `ResourceLeakConfigSig`:
 *
 * ```
 * class UnjoinedThreadConfig implements ResourceLeakConfigSig {
 *   predicate isResource(DataFlow::Node node) {
 *     node.asExpr().isThreadCreate()
 *   }
 *
 *   predicate isFree(ControlFlowNode node, DataFlow::Node resource) {
 *     node.asExpr().isThreadJoin(resource.asExpr())
 *   }
 * }
 * ```
 *
 * You can now check if a resource is leaked through the module predicate
 * `ResourceLeak<UnjoinedThreadConfig>::isLeaked(resource)`.
 *
 * The leak analysis finds the exit point of the function in which the resource is is declared, and
 * then reverses execution from there using `getAPredecessor()`. When this backwards walk discovers
 * a control flow node that frees the resource, that exploration stops. If any exploration reaches
 * a resource, that resource may be leaked via that path.
 *
 * Uses `DataFlow::Node` in order to track aliases of the resource to better detect when the
 * resource is freed.
 *
 * This library by default assumes that resources are expression nodes. To use it with other kinds
 * of nodes requires overriding `resourceInitPoint`.
 */
signature module ResourceLeakConfigSig {
  predicate isAllocate(ControlFlowNode node, DataFlow::Node resource);

  predicate isFree(ControlFlowNode node, DataFlow::Node resource);

  bindingset[node]
  default DataFlow::Node getAnAlias(DataFlow::Node node) {
    DataFlow::localFlow(node, result)
    or
    exists(Expr current, Expr after |
      current in [node.asExpr(), node.asDefiningArgument()] and
      after in [result.asExpr(), result.asDefiningArgument()] and
      hashCons(current) = hashCons(after) and
      strictlyDominates(current, after)
    )
  }

  /* A point at which a resource is considered to have leaked if it has not been freed. */
  default ControlFlowNode outOfScope(ControlFlowNode allocPoint) {
    result = allocPoint.(Expr).getEnclosingFunction().getBlock().getLastStmt()
  }
}

module ResourceLeak<ResourceLeakConfigSig Config> {
  private newtype TResource =
    TJustResource(DataFlow::Node resource, ControlFlowNode cfgNode) {
      Config::isAllocate(cfgNode, resource)
    }

  private predicate isLeakedAtControlPoint(TResource resource, ControlFlowNode cfgNode) {
    // Holds if this control point is where the resource was allocated (and therefore not freed).
    resource = TJustResource(_, cfgNode)
    or
    // Holds if this control point does not free the resource, and is reachable from a point that
    // does not free the resource.
    isLeakedAtControlPoint(resource, cfgNode.getAPredecessor()) and
    not exists(DataFlow::Node freed, DataFlow::Node resourceNode |
      Config::isFree(cfgNode, freed) and
      freed = Config::getAnAlias(resourceNode) and
      resource = TJustResource(resourceNode, _)
    )
  }

  /**
   * Holds if `resource` is leaked. Use this module predicate to find leaked resources.
   */
  ControlFlowNode getALeak(ControlFlowNode allocPoint) {
    exists(TResource resourceWrapper, DataFlow::Node resource |
      resourceWrapper = TJustResource(resource, allocPoint) and
      result = Config::outOfScope(allocPoint) and
      isLeakedAtControlPoint(resourceWrapper, result)
    )
  }
}
