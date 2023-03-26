/**
 * @id c/misra/every-switch-shall-have-default-label
 * @name RULE-16-4: Every switch statement shall have a default label
 * @description A default label that has no statements or a comment explaining why this is correct
 *              indicates a missing implementation that may result in unexpected behavior when the
 *              default case is executed.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-16-4
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

Stmt getFirstNonBlockStatement(BlockStmt bs) {
  exists(Stmt nextStmt | nextStmt = bs.getStmt(0) |
    if nextStmt instanceof BlockStmt
    then result = getFirstNonBlockStatement(nextStmt)
    else result = nextStmt
  )
}

Stmt getFirstStatement(DefaultCase case) {
  exists(Stmt next | next = case.getFollowingStmt() |
    if next instanceof BlockStmt then result = getFirstNonBlockStatement(next) else result = next
  )
}

from SwitchStmt switch, string message
where
  not isExcluded(switch, Statements1Package::everySwitchShallHaveDefaultLabelQuery()) and
  not switch.hasDefaultCase() and
  message = "has missing default clause."
  or
  exists(SwitchCase case, BreakStmt break |
    switch.getDefaultCase() = case and
    getFirstStatement(case) = break and
    not exists(Comment comment | comment.getCommentedElement() = break) and
    message =
      "has default label that does not terminate in a statement or comment before break statement"
  )
select switch, "$@ statement " + message, switch, "Switch"
