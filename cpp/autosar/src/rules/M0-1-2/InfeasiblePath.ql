/**
 * @id cpp/autosar/infeasible-path
 * @name M0-1-2: A project shall not contain infeasible paths
 * @description Infeasible paths complicate the program and can indicate a possible mistake on the
 *              part of the programmer.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/m0-1-2
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.invariantcondition.InvariantCondition

/**
 * A `Loop` that contains a `break` statement.
 */
class BreakingLoop extends Loop {
  BreakingLoop() { exists(BreakStmt break | this = break.getBreakable()) }
}

module AutosarConfig implements InvariantConditionConfigSig {
  Query getQuery() { result = DeadCodePackage::infeasiblePathQuery() }

  predicate isException(ControlFlowNode node) {
    node.getEnclosingElement() instanceof BreakingLoop and
    exists(node.getATrueSuccessor())
    or
    // Ignore conditions affected by macros, as they may include deliberate infeasible paths, or
    // paths which are only feasible in certain macro expansions
    node.isAffectedByMacro()
    or
    // Only consider reachability in uninstantiated templates, to avoid false positives
    node.isFromTemplateInstantiation(_)
  }
}

// Import the problems query predicate
import InvariantCondition<AutosarConfig>
