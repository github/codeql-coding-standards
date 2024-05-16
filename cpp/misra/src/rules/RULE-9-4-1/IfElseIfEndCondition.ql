/**
 * @id cpp/misra/if-else-if-end-condition
 * @name RULE-9-4-1: All if 
 * @description All if ... else if constructs shall be terminated with an else statement.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-9-4-1
 *       readability
 *       maintainability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.ifelseterminationconstruct.IfElseTerminationConstruct

class IfElseIfEndConditionQuery extends IfElseTerminationConstructSharedQuery {
  IfElseIfEndConditionQuery() {
    this = ImportMisra23Package::ifElseIfEndConditionQuery()
  }
}
