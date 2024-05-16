/**
 * @id cpp/misra/identifiers-used-in-the-controlling-expression-of
 * @name RULE-19-1-3: All identifiers used in the controlling expression of #if or #elif preprocessing directives shall be
 * @description All identifiers used in the controlling expression of #if or #elif preprocessing
 *              directives shall be defined prior to evaluation.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-19-1-3
 *       correctness
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.undefinedmacroidentifiers.UndefinedMacroIdentifiers

class IdentifiersUsedInTheControllingExpressionOfQuery extends UndefinedMacroIdentifiersSharedQuery {
  IdentifiersUsedInTheControllingExpressionOfQuery() {
    this = ImportMisra23Package::identifiersUsedInTheControllingExpressionOfQuery()
  }
}
