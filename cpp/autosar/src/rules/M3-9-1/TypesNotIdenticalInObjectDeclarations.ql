/**
 * @id cpp/autosar/types-not-identical-in-object-declarations
 * @name M3-9-1: Types shall be token-for-token identical in all declarations and re-declarations
 * @description The types used for an object or a function parameter shall be token-for-token
 *              identical in all declarations and re-declarations.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m3-9-1
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from VariableDeclarationEntry decl1, VariableDeclarationEntry decl2
where
  not isExcluded(decl1) and
  not isExcluded(decl2, DeclarationsPackage::typesNotIdenticalInObjectDeclarationsQuery()) and
  decl1.getDeclaration() = decl2.getDeclaration() and
  not decl1.getType() = decl2.getType()
select decl2, "The types used on re-declaration $@ of object $@ are not a token for token match",
  decl2, decl2.getName(), decl1, decl1.getName()
