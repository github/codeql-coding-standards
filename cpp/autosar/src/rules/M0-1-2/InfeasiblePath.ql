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
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

/**
 * A "conditional" node in the control flow graph, i.e. one that can potentially have a true and false path.
 */
class ConditionalControlFlowNode extends ControlFlowNode {
  ConditionalControlFlowNode() {
    // A conditional node is one with at least one of a true or false successor
    (exists(getATrueSuccessor()) or exists(getAFalseSuccessor())) and
    // Ignore conditions affected by macros, as they may include deliberate infeasible paths, or
    // paths which are only feasible in certain macro expansions
    not isAffectedByMacro()
  }
}

/**
 * A `Loop` that contains a `break` statement.
 */
class BreakingLoop extends Loop {
  BreakingLoop() { exists(BreakStmt break | this = break.getBreakable()) }
}

/**
 * Holds if the `ConditionalNode` has an infeasible `path` according to the control flow graph library.
 */
predicate hasCFGDeducedInfeasiblePath(
  ConditionalControlFlowNode cond, boolean infeasiblePath, string explanation
) {
  // No true successor, so the true path has already been deduced as infeasible
  not exists(cond.getATrueSuccessor()) and
  infeasiblePath = true and
  explanation = "this expression consists of constants which evaluate to false"
  or
  // No false successor, so false path has already been deduced as infeasible
  not exists(cond.getAFalseSuccessor()) and
  not cond.getEnclosingStmt() instanceof BreakingLoop and
  infeasiblePath = false and
  explanation = "this expression consists of constants which evaluate to true"
}

predicate isConstantRelationalOperation(
  RelationalOperation rel, boolean infeasiblePath, string explanation
) {
  /*
   * This predicate identifies a number of a cases where we can conclusive determine that a relational
   * operation will always return true or false, based on the ranges for each operand as determined
   * by the SimpleRangeAnalysis library (and any extensions provide in the Coding Standards library).
   *
   * Important note: in order to deduce that an relational operation _always_ returns true or false,
   * we must ensure that it returns true or false for _all_ possible values of the operands. For
   * example, it may be tempting to look at this relational operation on these ranges:
   * ```
   *   [0..5] < [0..10]
   * ```
   * And say that ub(lesser) < ub(greater) and therefore it is `true`, however this is not the case
   * for all permutations (e.g. 5 < 0).
   *
   * Instead, we look at all four permutations of these two dimensions:
   *  - Equal-to or not equal-to
   *  - Always true or always false
   */

  // This restricts the comparison to occur directly within the conditional node
  // In theory we could also extend this to identify comparisons where the result is stored, then
  // later read in a conditional control flow node within the same function (using SSA)
  // Doing so would benefit from path explanations, but would require a more complex analysis
  rel instanceof ConditionalControlFlowNode and
  // If at least one operand includes an access of a volatile variable, the range analysis library may
  // provide inaccurate results, so we ignore this case
  not rel.getAnOperand().getAChild*().(VariableAccess).getTarget().isVolatile() and
  exists(boolean isEqual |
    if
      rel instanceof GEExpr
      or
      rel instanceof LEExpr
    then isEqual = true
    else isEqual = false
  |
    // Not equal-to/always true
    // If the largest value of the lesser operand is less than the smallest value of the greater
    // operand, then the LT/GT comparison is always true
    // Example: [0..5] < [6..10]
    upperBound(rel.getLesserOperand()) < lowerBound(rel.getGreaterOperand()) and
    explanation =
      rel.getLesserOperand() + " (max value: " + upperBound(rel.getLesserOperand()) +
        ") is always less than " + rel.getGreaterOperand() + " (minimum value: " +
        lowerBound(rel.getGreaterOperand()) + ")" and
    isEqual = false and
    infeasiblePath = false
    or
    // Equal-to/always true
    // If the largest value of the lesser operand is less than or equal to the smallest value of the
    // greater operand, then the LTE/GTE comparison is always true
    // Example: [0..6] <= [6..10]
    upperBound(rel.getLesserOperand()) <= lowerBound(rel.getGreaterOperand()) and
    explanation =
      rel.getLesserOperand() + " (max value: " + upperBound(rel.getLesserOperand()) +
        ") is always less than or equal to " + rel.getGreaterOperand() + " (minimum value: " +
        lowerBound(rel.getGreaterOperand()) + ")" and
    isEqual = true and
    infeasiblePath = false
    or
    // Equal to/always false
    // If the largest value of the greater operand is less than the smallest value of the lesser
    // operand, then the LTE/GTE comparison is always false
    // Example: [6..10] <= [0..5]
    upperBound(rel.getGreaterOperand()) < lowerBound(rel.getLesserOperand()) and
    explanation =
      rel.getGreaterOperand() + " (max value: " + upperBound(rel.getGreaterOperand()) +
        ") is always less than " + rel.getLesserOperand() + " (minimum value: " +
        lowerBound(rel.getLesserOperand()) + ")" and
    isEqual = true and
    infeasiblePath = true
    or
    // Equal to/always true
    // If the largest value of the greater operand is less than or equal to the smallest value of the
    // lesser operand, then the LT/GT comparison is always false
    // Example: [6..10] < [0..6]
    upperBound(rel.getGreaterOperand()) <= lowerBound(rel.getLesserOperand()) and
    explanation =
      rel.getGreaterOperand() + " (max value: " + upperBound(rel.getGreaterOperand()) +
        ") is always less than or equal to " + rel.getLesserOperand() + " (minimum value: " +
        lowerBound(rel.getLesserOperand()) + ")" and
    isEqual = false and
    infeasiblePath = true
  )
}

/**
 * Holds if the `ConditionalNode` has an infeasible `path` for the reason given in `explanation`.
 */
predicate hasInfeasiblePath(
  ConditionalControlFlowNode node, boolean infeasiblePath, string explanation
) {
  hasCFGDeducedInfeasiblePath(node, infeasiblePath, explanation) and
  not isConstantRelationalOperation(node, infeasiblePath, _)
  or
  isConstantRelationalOperation(node, infeasiblePath, explanation)
}

from ConditionalControlFlowNode cond, boolean infeasiblePath, string explanation
where
  not isExcluded(cond) and
  hasInfeasiblePath(cond, infeasiblePath, explanation)
select cond, "The " + infeasiblePath + " path is infeasible because " + explanation + "."
