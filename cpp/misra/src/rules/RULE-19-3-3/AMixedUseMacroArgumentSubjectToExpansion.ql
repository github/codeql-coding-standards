/**
 * @id cpp/misra/a-mixed-use-macro-argument-subject-to-expansion
 * @name RULE-19-3-3: The argument to a mixed-use macro parameter shall not be subject to further expansion
 * @description The argument to a mixed-use macro parameter shall not be subject to further
 *              expansion.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-19-3-3
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.amixedusemacroargumentsubjecttoexpansion.AMixedUseMacroArgumentSubjectToExpansion

class AMixedUseMacroArgumentSubjectToExpansionQuery extends AMixedUseMacroArgumentSubjectToExpansionSharedQuery
{
  AMixedUseMacroArgumentSubjectToExpansionQuery() {
    this = ImportMisra23Package::aMixedUseMacroArgumentSubjectToExpansionQuery()
  }
}
