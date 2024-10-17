/**
 * @id c/misra/missing-static-specifier-func-redeclaration-obsolete
 * @name RULE-1-5: If a function has internal linkage then all re-declarations shall include the static storage class
 * @description Declaring a function with internal linkage without the static storage class
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
import codingstandards.cpp.rules.missingstaticspecifierfunctionredeclarationshared.MissingStaticSpecifierFunctionRedeclarationShared

class MissingStaticSpecifierFuncRedeclarationObsoleteQuery extends MissingStaticSpecifierFunctionRedeclarationSharedSharedQuery {
  MissingStaticSpecifierFuncRedeclarationObsoleteQuery() {
    this = Language4Package::missingStaticSpecifierFuncRedeclarationObsoleteQuery()
  }
}
