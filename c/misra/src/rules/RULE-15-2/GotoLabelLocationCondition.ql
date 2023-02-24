/**
 * @id c/misra/goto-label-location-condition
 * @name RULE-15-2: The goto statement shall jump to a label declared later in the same function
 * @description Unconstrained use of goto can lead to unstructured code.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-15-2
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.gotostatementcondition.GotoStatementCondition

class GotoLabelLocationConditionQuery extends GotoStatementConditionSharedQuery {
  GotoLabelLocationConditionQuery() {
    this = Statements2Package::gotoLabelLocationConditionQuery()
  }
}
