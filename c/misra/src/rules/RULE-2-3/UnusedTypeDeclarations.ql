/**
 * @id c/misra/unused-type-declarations
 * @name RULE-2-3: A project should not contain unused type declarations
 * @description Unused type declarations are either redundant or indicate a possible mistake on the
 *              part of the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-2-3
 *       readability
 *       maintainability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.unusedtypedeclarations.UnusedTypeDeclarations

class UnusedTypeDeclarationsQuery extends UnusedTypeDeclarationsSharedQuery {
  UnusedTypeDeclarationsQuery() { this = DeadCodePackage::unusedTypeDeclarationsQuery() }
}
