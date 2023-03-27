/**
 * @id cpp/autosar/goto-statement-jump-condition
 * @name M6-6-2: The goto statement shall jump to a label declared later in the same function body
 * @description Jumping back to an earlier section in the code can lead to accidental iterations.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-6-2
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.gotostatementcondition.GotoStatementCondition

class GotoStatementJumpConditionQuery extends GotoStatementConditionSharedQuery {
  GotoStatementJumpConditionQuery() {
    this = ConditionalsPackage::gotoStatementJumpConditionQuery()
  }
}
