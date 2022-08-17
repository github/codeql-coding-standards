/**
 * @id cpp/autosar/comma-operator-used
 * @name M5-18-1: The comma operator shall not be used
 * @description The comma operator shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-18-1
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.commaoperatorused.CommaOperatorUsed

class CommaOperatorUsedQuery extends CommaOperatorUsedSharedQuery {
  CommaOperatorUsedQuery() {
    this = BannedSyntaxPackage::commaOperatorUsedQuery()
  }
}
