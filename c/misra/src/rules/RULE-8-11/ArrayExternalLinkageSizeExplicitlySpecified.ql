/**
 * @id c/misra/array-external-linkage-size-explicitly-specified
 * @name RULE-8-11: When an array with external linkage is declared, its size should be explicitly specified
 * @description Declaring an array without an explicit size disallows the compiler and static
 *              checkers from doing array bounds analysis and can lead to less readable, unsafe
 *              code.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-11
 *       correctness
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Identifiers

from VariableDeclarationEntry v, ArrayType t
where
  not isExcluded(v, Declarations6Package::arrayExternalLinkageSizeExplicitlySpecifiedQuery()) and
  v.getDeclaration() instanceof ExternalIdentifiers and
  v.getType() = t and
  not exists(t.getSize()) and
  //this rule applies to non-defining declarations only
  not v.isDefinition()
select v, "Array declared without explicit size."
