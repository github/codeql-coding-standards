/**
 * @id cpp/misra/appropriate-structure-of-switch-statement
 * @name RULE-9-4-2: The structure of a switch statement shall be appropriate
 * @description A switch statement should have an appropriate structure with proper cases, default
 *              labels, and break statements to ensure clear control flow and prevent unintended
 *              fall-through behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-9-4-2
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/allocated-target/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.SwitchStatement

from SwitchStmt switch, string message
where
  not isExcluded(switch, StatementsPackage::appropriateStructureOfSwitchStatementQuery()) and
  (
    // RULE-16-1: Switch not well-formed (has inappropriate statements)
    exists(SwitchCase case |
      case = switch.getASwitchCase() and
      switchCaseNotWellFormed(case) and
      message = "has a case that contains inappropriate statements (only expression, compound, selection, iteration or try statements are allowed)"
    )
    or
    // RULE-16-2: Nested switch labels
    exists(SwitchCase case |
      case = switch.getASwitchCase() and
      case instanceof NestedSwitchCase and
      message = "contains a switch label that is not directly within the switch body"
    )
    or
    // RULE-16-3: Non-empty case doesn't terminate with break
    exists(SwitchCase case |
      case = switch.getASwitchCase() and
      case instanceof CaseDoesNotTerminate and
      message = "has a non-empty case that does not terminate with an unconditional break or throw statement"
    )
    or
    // RULE-16-4: Missing default clause
    not switch.hasDefaultCase() and
    message = "is missing a default clause"
    or
    // RULE-16-5: Default clause not first or last
    exists(SwitchCase defaultCase |
      switch.getDefaultCase() = defaultCase and
      exists(defaultCase.getPreviousSwitchCase()) and
      finalClauseInSwitchNotDefault(switch) and
      message = "has a default clause that is not the first or last switch label"
    )
    or
    // RULE-16-6: Less than two case clauses
    count(SwitchCase case |
      switch.getASwitchCase() = case and
      case.getNextSwitchCase() != case.getFollowingStmt()
    ) + 1 < 2 and
    message = "has fewer than two switch-clauses"
    or
    // RULE-16-7: Boolean switch expression
    switch instanceof BooleanSwitchStmt and
    message = "has a controlling expression of essentially Boolean type"
  )
select switch, "Switch statement " + message + "."
