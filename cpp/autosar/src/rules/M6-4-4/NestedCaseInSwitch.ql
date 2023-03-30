/**
 * @id cpp/autosar/nested-case-in-switch
 * @name M6-4-4: A switch-label shall only be used when the most closely-enclosing compound statement is the body of a switch statement
 * @description Nested switch labels cause undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-4-4
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.nestedlabelinswitch.NestedLabelInSwitch

class NestedCaseInSwitchQuery extends NestedLabelInSwitchSharedQuery {
  NestedCaseInSwitchQuery() {
    this = ConditionalsPackage::nestedCaseInSwitchQuery()
  }
}
