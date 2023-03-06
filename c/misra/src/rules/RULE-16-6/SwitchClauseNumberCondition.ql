/**
 * @id c/misra/switch-clause-number-condition
 * @name RULE-16-6: Every switch statement shall have at least two switch-clauses
 * @description Switch Statements with a single path are redundant and may cause programming errors.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-16-6
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from SwitchStmt switch
where
  not isExcluded(switch, Statements2Package::switchClauseNumberConditionQuery()) and
  count(SwitchCase case |
      switch.getASwitchCase() = case and
      case.getNextSwitchCase() != case.getFollowingStmt()
    ) + 1 < 2
select switch, "$@ statement has a single path.", switch, "Switch"
