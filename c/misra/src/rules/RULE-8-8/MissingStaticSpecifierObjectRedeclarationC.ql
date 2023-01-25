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
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from VariableDeclarationEntry redeclaration, VariableDeclarationEntry de
where
  not isExcluded(redeclaration,
    Declarations5Package::missingStaticSpecifierObjectRedeclarationCQuery()) and
  //following implies de != redeclaration
  de.hasSpecifier("static") and
  not redeclaration.hasSpecifier("static") and
  de.getDeclaration().isTopLevel() and
  redeclaration.getDeclaration() = de.getDeclaration()
select redeclaration, "The redeclaration of $@ with internal linkage misses the static specifier.",
  de, de.getName()
