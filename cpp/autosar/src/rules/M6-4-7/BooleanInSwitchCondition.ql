/**
 * @id cpp/autosar/boolean-in-switch-condition
 * @name M6-4-7: The condition of a switch statement shall not have bool type
 * @description An if statement is more appropriate for bool type.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-4-7
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SwitchStatement

from BooleanSwitchStmt switch
where not isExcluded(switch, ConditionalsPackage::booleanInSwitchConditionQuery())
select switch, "The condition of this $@ statement has boolean type", switch, "switch"
