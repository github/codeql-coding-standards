/**
 * Provides a library with a `problems` predicate for the following issue:
 * Declaring an identifier with internal linkage without the static storage class
 * specifier is an obselescent feature.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class MissingStaticSpecifierObjectRedeclarationSharedSharedQuery extends Query { }

Query getQuery() { result instanceof MissingStaticSpecifierObjectRedeclarationSharedSharedQuery }

query predicate problems(
  VariableDeclarationEntry redeclaration, string message, VariableDeclarationEntry de,
  string deString
) {
  not isExcluded(redeclaration, getQuery()) and
  //following implies de != redeclaration
  de.hasSpecifier("static") and
  not redeclaration.hasSpecifier("static") and
  de.getDeclaration().isTopLevel() and
  redeclaration.getDeclaration() = de.getDeclaration() and
  message = "The redeclaration of $@ with internal linkage misses the static specifier." and
  deString = de.getName()
}
