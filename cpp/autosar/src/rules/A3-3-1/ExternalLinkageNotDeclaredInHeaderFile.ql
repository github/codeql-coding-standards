/**
 * @id cpp/autosar/external-linkage-not-declared-in-header-file
 * @name A3-3-1: Objects or functions with external linkage (including members of named namespaces) shall be declared in a header file
 * @description Using objects or functions with external linkage in implementation files makes code
 *              harder to understand.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a3-3-1
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Linkage
import codingstandards.cpp.EncapsulatingFunctions

from DeclarationEntry de, string kind
where
  not isExcluded(de, IncludesPackage::externalLinkageNotDeclaredInHeaderFileQuery()) and
  hasExternalLinkage(de.getDeclaration()) and
  // Exclude subobjects such as struct members or member functions
  de.getDeclaration().isTopLevel() and
  // The declaration with external linkage does not have a declaration in a header file
  exists(Compilation c | de.getFile() = c.getAFileCompiled()) and
  not exists(DeclarationEntry otherDe |
    de.getDeclaration() = otherDe.getDeclaration() and
    not de = otherDe and
    not otherDe.isDefinition()
  |
    otherDe.getFile() instanceof HeaderFile
  ) and
  // Main functions are an exception to the rule
  not de.getDeclaration() instanceof MainFunction and
  if de.getDeclaration() instanceof Function then kind = "function" else kind = "object"
select de, "Externally linked " + kind + " " + de.getName() + " not declared in header file."
