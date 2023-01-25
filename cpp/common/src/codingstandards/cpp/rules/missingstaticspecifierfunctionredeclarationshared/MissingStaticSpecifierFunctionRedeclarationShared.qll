/**
 * Provides a library which includes a `problems` predicate for reporting missing static specifiers for redeclarations of functions with internal linkage.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class MissingStaticSpecifierFunctionRedeclarationSharedSharedQuery extends Query { }

Query getQuery() { result instanceof MissingStaticSpecifierFunctionRedeclarationSharedSharedQuery }

query predicate problems(
  FunctionDeclarationEntry redeclaration, string message, FunctionDeclarationEntry fde,
  string msgpiece
) {
  not isExcluded(redeclaration, getQuery()) and
  fde.hasSpecifier("static") and
  fde.getDeclaration().isTopLevel() and
  redeclaration.getDeclaration() = fde.getDeclaration() and
  not redeclaration.hasSpecifier("static") and
  fde != redeclaration and
  message = "The redeclaration of $@ with internal linkage misses the static specifier." and
  msgpiece = "function"
}
