/**
 * @id c/misra/missing-static-specifier-object-redeclaration-c
 * @name RULE-8-8: If an object has internal linkage then all re-declarations shall include the static storage class
 * @description If an object has internal linkage then all re-declarations shall include the static
 *              storage class specifier to make the internal linkage explicit.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-8-8
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 *       coding-standards/baseline/safety
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.missingstaticspecifierobjectredeclarationshared.MissingStaticSpecifierObjectRedeclarationShared

class MissingStaticSpecifierObjectRedeclarationCQuery extends MissingStaticSpecifierObjectRedeclarationSharedSharedQuery
{
  MissingStaticSpecifierObjectRedeclarationCQuery() {
    this = Declarations5Package::missingStaticSpecifierObjectRedeclarationCQuery()
  }
}
