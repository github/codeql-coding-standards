/**
 * Provides a library with a `problems` predicate for the following issue:
 * Using objects or functions with external linkage in implementation files makes code
 * harder to understand.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Linkage
import codingstandards.cpp.EncapsulatingFunctions

abstract class ExternalLinkageNotDeclaredInHeaderFileSharedQuery extends Query { }

Query getQuery() { result instanceof ExternalLinkageNotDeclaredInHeaderFileSharedQuery }

query predicate problems(DeclarationEntry de, string message) {
  not isExcluded(de, getQuery()) and
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
  if de.getDeclaration() instanceof Function
  then message = "Externally linked function '" + de.getName() + "' not declared in header file."
  else message = "Externally linked object '" + de.getName() + "' not declared in header file."
}
