/**
 * @id c/misra/if-else-end-condition
 * @name RULE-15-7: All if / else if constructs shall be terminated with an else statement
 * @description Terminating an `if...else` construct is a defensive programming technique.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-15-7
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.ifelseterminationconstruct.IfElseTerminationConstruct

class IfElseEndConditionQuery extends IfElseTerminationConstructSharedQuery {
  IfElseEndConditionQuery() {
    this = Statements3Package::ifElseEndConditionQuery()
  }
}
