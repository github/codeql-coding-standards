/**
 * @id c/misra/comma-operator-should-not-be-used
 * @name RULE-12-3: The comma operator should not be used
 * @description Use of the comma operator may affect the readability of the code.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-12-3
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.commaoperatorused.CommaOperatorUsed

class CommaOperatorShouldNotBeUsedQuery extends CommaOperatorUsedSharedQuery {
  CommaOperatorShouldNotBeUsedQuery() {
    this = BannedPackage::commaOperatorShouldNotBeUsedQuery()
  }
}
