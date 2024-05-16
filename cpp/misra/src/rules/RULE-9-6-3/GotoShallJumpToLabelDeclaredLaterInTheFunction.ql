/**
 * @id cpp/misra/goto-shall-jump-to-label-declared-later-in-the-function
 * @name RULE-9-6-3: The goto statement shall jump to a label declared later in the function body
 * @description 
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-9-6-3
 *       maintainability
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.gotostatementcondition.GotoStatementCondition

class GotoShallJumpToLabelDeclaredLaterInTheFunctionQuery extends GotoStatementConditionSharedQuery {
  GotoShallJumpToLabelDeclaredLaterInTheFunctionQuery() {
    this = ImportMisra23Package::gotoShallJumpToLabelDeclaredLaterInTheFunctionQuery()
  }
}
