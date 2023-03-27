/**
 * @id c/misra/switch-case-start-condition
 * @name RULE-16-1: A well formed switch statement must start with a case clause
 * @description The switch statement syntax is weak and may lead to unspecified behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-16-1
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.switchcasepositioncondition.SwitchCasePositionCondition

class SwitchCaseStartConditionQuery extends SwitchCasePositionConditionSharedQuery {
  SwitchCaseStartConditionQuery() {
    this = Statements3Package::switchCaseStartConditionQuery()
  }
}
