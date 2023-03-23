/**
 * @id c/misra/compatible-declaration-object-defined
 * @name RULE-8-4: A compatible declaration shall be visible when an object with external linkage is defined
 * @description A compatible declaration shall be visible when an object with external linkage is
 *              defined, otherwise program behaviour may be undefined.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-4
 *       readability
 *       maintainability
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Identifiers
import codingstandards.cpp.Compatible

from VariableDeclarationEntry decl1
where
  not isExcluded(decl1, Declarations4Package::compatibleDeclarationObjectDefinedQuery()) and
  decl1.isDefinition() and
  decl1.getDeclaration() instanceof ExternalIdentifiers and
  // no declaration matches
  not exists(VariableDeclarationEntry decl2 |
    not decl2.isDefinition() and
    decl1.getDeclaration() = decl2.getDeclaration() and
    typesCompatible(decl1.getType(), decl2.getType())
  )
select decl1, "No separate compatible declaration found for this definition."
