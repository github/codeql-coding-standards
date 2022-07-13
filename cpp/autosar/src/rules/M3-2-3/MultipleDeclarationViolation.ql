/**
 * @id cpp/autosar/multiple-declaration-violation
 * @name M3-2-3: A type, object or function that is used in multiple translation units shall be declared in a single file
 * @description A type, object or function that is used in multiple translation units shall be
 *              declared in one and only one file to prevent inconsistent declarations that can
 *              result in unexpected behavior.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/m3-2-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Scope

from DeclarationEntry de, DeclarationEntry otherDeclaration, string kind
where
  not isExcluded(de) and
  exists(Declaration d |
    de.getDeclaration() = d and
    otherDeclaration.getDeclaration() = d and
    de.getFile() != otherDeclaration.getFile() and
    not de.getFile() instanceof HeaderFile and
    not otherDeclaration.getFile() instanceof HeaderFile
  ) and
  (
    de.getDeclaration() instanceof Function and kind = "function"
    or
    de.getDeclaration() instanceof Variable and
    not de.getDeclaration() instanceof Parameter and
    kind = "variable"
    or
    de.getDeclaration() instanceof Type and
    not de.getDeclaration() instanceof UsingAliasTypedefType and
    kind = "type"
  ) and
  not otherDeclaration.isDefinition() and
  not de.isInMacroExpansion()
select de,
  "The " + kind + " declaration " + de.getName() +
    " is used in multiple translations units and has an additional $@.", otherDeclaration,
  "declaration"
