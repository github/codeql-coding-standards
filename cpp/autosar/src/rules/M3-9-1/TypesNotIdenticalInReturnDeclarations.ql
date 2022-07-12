/**
 * @id cpp/autosar/types-not-identical-in-return-declarations
 * @name M3-9-1: Types shall be token-for-token identical in all declarations and re-declarations
 * @description The types used for a function return type shall be token-for-token identical in all
 *              declarations and re-declarations.
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
import cpp
import codingstandards.cpp.autosar

from FunctionDeclarationEntry f1, FunctionDeclarationEntry f2
where
  not isExcluded(f1) and
  not isExcluded(f2, DeclarationsPackage::typesNotIdenticalInReturnDeclarationsQuery()) and
  f1.getDeclaration() = f2.getDeclaration() and
  not f1.getType() = f2.getType()
select f1, "The return type of the re-declaration $@ of $@ is not a token for token match", f1,
  f1.getName(), f2, f2.getName()
