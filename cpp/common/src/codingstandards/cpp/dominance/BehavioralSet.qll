import cpp
import semmle.code.cpp.controlflow.ControlFlowGraph

signature class TargetNode extends ControlFlowNode;

signature module DominatingSetConfigSig<TargetNode Target> {
  predicate isTargetBehavior(ControlFlowNode behavior, Target target);

  default predicate isBlockingBehavior(ControlFlowNode behavior, Target target) { none() }
}

/**
 * A module to find whether there exists a dominator set for a node which performs a relevant
 * behavior.
 *
 * For instance, we may wish to see that all paths leading to an `abort()` statement include a
 * logging call. In this case, the `abort()` statement is the `Target` node, and the config module
 * predicate `isTargetBehavior` logging statements.
 *
 * Additionally, the config may specify `isBlockingBehavior` to prevent searching too far for the
 * relevant behavior. For instance, if analyzing that all paths to an `fflush()` call are preceded
 * by a write, we should ignore paths from write operations that have already been flushed through
 * an intermediary `fflush()` call.
 */
module DominatingBehavioralSet<TargetNode Target, DominatingSetConfigSig<Target> Config> {
  /**
   * Holds if this search step can reach the entry or a blocking node, without passing through a
   * target behavior, indicating that the target is has no relevant dominator set.
   */
  private predicate searchStep(ControlFlowNode node, Target target) {
    Config::isBlockingBehavior(node, target)
    or
    not Config::isTargetBehavior(node, target) and
    exists(ControlFlowNode prev | prev = node.getAPredecessor() | searchStep(prev, target))
  }

  predicate isDominatedByBehavior(Target target) {
    forex(ControlFlowNode prev | prev = target.getAPredecessor() | not searchStep(prev, target))
  }
}
