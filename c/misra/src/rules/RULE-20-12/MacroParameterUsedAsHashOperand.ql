/**
 * @id c/misra/macro-parameter-used-as-hash-operand
 * @name RULE-20-12: A macro parameter used as an operand to the # or ## operators shall only be used as an operand to these operators
 * @description A macro parameter used in different contexts such as: 1) an operand to the # or ##
 *              operators where it is not expanded, versus 2) elsewhere where it is expanded, makes
 *              code more difficult to understand.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-20-12
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.amixedusemacroargumentsubjecttoexpansion_shared.AMixedUseMacroArgumentSubjectToExpansion_shared

class MacroParameterUsedAsHashOperandQuery extends AMixedUseMacroArgumentSubjectToExpansion_sharedSharedQuery {
  MacroParameterUsedAsHashOperandQuery() {
    this = Preprocessor2Package::macroParameterUsedAsHashOperandQuery()
  }
}
