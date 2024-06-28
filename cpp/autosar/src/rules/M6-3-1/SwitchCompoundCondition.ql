/**
 * @id cpp/autosar/switch-compound-condition
 * @name M6-3-1: The statement forming the body of a switch shall be a compound statement
 * @description If the body of a switch is not enclosed in braces, then this can lead to incorrect
 *              execution, and hard for developers to maintain.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-3-1
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.switchcompoundcondition_shared.SwitchCompoundCondition_shared

class SwitchCompoundConditionQuery extends SwitchCompoundCondition_sharedSharedQuery {
  SwitchCompoundConditionQuery() { this = ConditionalsPackage::switchCompoundConditionQuery() }
}
