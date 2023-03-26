/**
 * @id c/misra/default-not-first-or-last-of-switch
 * @name RULE-16-5: A default label shall appear as either the first or the last switch label or a switch statement
 * @description Locating the default label is easier when it is the first or last label.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-16-5
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.SwitchStatement

from SwitchStmt switch, SwitchCase defaultCase
where
  not isExcluded(switch, Statements1Package::defaultNotFirstOrLastOfSwitchQuery()) and
  switch.getDefaultCase() = defaultCase and
  exists(defaultCase.getPreviousSwitchCase()) and
  finalClauseInSwitchNotDefault(switch)
select defaultCase, "$@ statement does not have $@ case as first or last switch label.", switch,
  "Switch", defaultCase, "default"
