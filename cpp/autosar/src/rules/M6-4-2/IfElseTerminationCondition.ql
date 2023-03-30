/**
 * @id cpp/autosar/if-else-termination-condition
 * @name M6-4-2: All if ... else if constructs shall be terminated with an else clause
 * @description The final else statement is a defensive programming technique.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-4-2
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.ifelseterminationconstruct.IfElseTerminationConstruct

class IfElseTerminationConditionQuery extends IfElseTerminationConstructSharedQuery {
  IfElseTerminationConditionQuery() {
    this = ConditionalsPackage::ifElseTerminationConditionQuery()
  }
}
