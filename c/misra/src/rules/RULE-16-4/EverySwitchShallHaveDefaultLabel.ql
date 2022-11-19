/**
 * @id c/misra/every-switch-shall-have-default-label
 * @name RULE-16-4: Every switch statement shall have a default label
 * @description The requirement for a default label is defensive programming.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-16-4
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from SwitchStmt switch, string message
where
  not isExcluded(switch, Statements1Package::everySwitchShallHaveDefaultLabelQuery()) and
  not switch.hasDefaultCase() and
  message = "has missing default clause."
  or
  exists(SwitchCase case, BreakStmt break |
    switch.getDefaultCase() = case and
    case.getFollowingStmt() = break and
    not exists(Comment comment |
      break.getLocation().getEndLine() - 1 = comment.getLocation().getEndLine()
    ) and
    message =
      "has default label that does not terminate in a statement or comment before break statement"
  )
select switch, "$@ statement " + message, switch, "Switch"
