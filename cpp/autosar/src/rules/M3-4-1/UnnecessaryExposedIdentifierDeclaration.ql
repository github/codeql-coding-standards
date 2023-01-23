/**
 * @id cpp/autosar/unnecessary-exposed-identifier-declaration
 * @name M3-4-1: An identifier declared to be an object or type shall be defined in a block that minimizes its visibility
 * @description An identifier declared to be an object or type shall be defined in a block that
 *              minimizes its visibility to prevent any accidental use of the identifier.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/m3-4-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.unnecessaryexposedidentifierdeclarationshared.UnnecessaryExposedIdentifierDeclarationShared

class UnnecessaryExposedIdentifierDeclarationQuery extends UnnecessaryExposedIdentifierDeclarationSharedSharedQuery {
  UnnecessaryExposedIdentifierDeclarationQuery() {
    this = ScopePackage::unnecessaryExposedIdentifierDeclarationQuery()
  }
}
