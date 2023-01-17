/**
 * @id c/misra/unnecessary-exposed-identifier-declaration-c
 * @name RULE-8-9: An object should be defined at block scope if its identifier only appears in a single function
 * @description An identifier declared to be an object or type shall be defined in a block that
 *              minimizes its visibility to prevent any accidental use of the identifier.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-8-9
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.unnecessaryexposedidentifierdeclarationshared.UnnecessaryExposedIdentifierDeclarationShared

class UnnecessaryExposedIdentifierDeclarationCQuery extends UnnecessaryExposedIdentifierDeclarationSharedSharedQuery {
  UnnecessaryExposedIdentifierDeclarationCQuery() {
    this = Declarations5Package::unnecessaryExposedIdentifierDeclarationCQuery()
  }
}
