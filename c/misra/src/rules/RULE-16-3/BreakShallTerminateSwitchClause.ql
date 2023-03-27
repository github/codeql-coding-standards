/**
 * @id c/misra/break-shall-terminate-switch-clause
 * @name RULE-16-3: An unconditional break statement shall terminate every switch-clause
 * @description An unterminated switch-clause occurring at the end of a switch statement may fall
 *              into switch clauses which are added later.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-16-3
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from SwitchCase case
where
  not isExcluded(case, Statements1Package::breakShallTerminateSwitchClauseQuery()) and
  not case.terminatesInBreakStmt() and
  not case.getFollowingStmt() instanceof SwitchCase
select case, "The switch $@ does not terminate with a break statement.", case, "clause"
