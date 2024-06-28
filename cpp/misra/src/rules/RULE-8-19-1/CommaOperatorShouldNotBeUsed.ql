/**
 * @id cpp/misra/comma-operator-should-not-be-used
 * @name RULE-8-19-1: The comma operator should not be used
 * @description The comma operator should not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-19-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.commaoperatorused.CommaOperatorUsed

class CommaOperatorShouldNotBeUsedQuery extends CommaOperatorUsedSharedQuery {
  CommaOperatorShouldNotBeUsedQuery() {
    this = ImportMisra23Package::commaOperatorShouldNotBeUsedQuery()
  }
}
