/**
 * @id cpp/autosar/switch-final-clause-not-default
 * @name M6-4-6: The final clause of a switch statement shall be the default-clause
 * @description This is a defensive programming technique.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-4-6
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SwitchStatement

from SwitchStmt switch
where
  not isExcluded(switch, ConditionalsPackage::switchFinalClauseNotDefaultQuery()) and
  finalClauseInSwitchNotDefault(switch)
select switch, "The final clause of this $@ statement is not a default clause.", switch, "switch"
