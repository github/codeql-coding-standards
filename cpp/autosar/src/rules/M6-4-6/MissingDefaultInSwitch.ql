/**
 * @id cpp/autosar/missing-default-in-switch
 * @name M6-4-6: Missing default-clause in switch
 * @description This is a defensive programming technique. The exception to this is if the condition
 *              of the switch statement is of type enum and all of the enum values are included in
 *              case labels.
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
  not isExcluded(switch, ConditionalsPackage::missingDefaultInSwitchQuery()) and
  missingDefaultClause(switch)
select switch, "This $@ statement is missing a final default clause.", switch, "switch"
