/**
 * @id c/misra/missing-static-specifier-function-redeclaration-c
 * @name RULE-8-8: If a function has internal linkage then all re-declarations shall include the static storage class
 * @description If a function has internal linkage then all re-declarations shall include the static
 *              storage class specifier to make the internal linkage explicit.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-8-8
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.missingstaticspecifierfunctionredeclarationshared.MissingStaticSpecifierFunctionRedeclarationShared

class MissingStaticSpecifierFunctionRedeclarationCQuery extends MissingStaticSpecifierFunctionRedeclarationSharedSharedQuery {
  MissingStaticSpecifierFunctionRedeclarationCQuery() {
    this = Declarations5Package::missingStaticSpecifierFunctionRedeclarationCQuery()
  }
}
