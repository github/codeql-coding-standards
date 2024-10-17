/**
 * @id c/misra/missing-static-specifier-object-redeclaration-obsolete
 * @name RULE-1-5: If an object has internal linkage then all re-declarations shall include the static storage class
 * @description Declaring an identifier with internal linkage without the static storage class
 *              specifier is an obselescent feature.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-1-5
 *       readability
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.missingstaticspecifierobjectredeclarationshared.MissingStaticSpecifierObjectRedeclarationShared

class MissingStaticSpecifierObjectRedeclarationObsoleteQuery extends MissingStaticSpecifierObjectRedeclarationSharedSharedQuery {
  MissingStaticSpecifierObjectRedeclarationObsoleteQuery() {
    this = Language4Package::missingStaticSpecifierObjectRedeclarationObsoleteQuery()
  }
}
