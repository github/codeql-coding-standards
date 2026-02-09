/**
 * Provides a library with a `problems` predicate for the following issue:
 * Use of an identifier declared in an inner scope with an identical name to an
 * identifier in an outer scope can lead to inadvertent errors if the incorrect
 * identifier is modified.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Scope

abstract class IdentifierHiddenSharedQuery extends Query { }

Query getQuery() { result instanceof IdentifierHiddenSharedQuery }

query predicate problems(
  UserVariable innerDecl, string message, UserVariable outerDecl, string varName
) {
  not isExcluded(outerDecl, getQuery()) and
  not isExcluded(innerDecl, getQuery()) and
  //ignore template variables for this rule
  not outerDecl instanceof TemplateVariable and
  not innerDecl instanceof TemplateVariable and
  hidesStrict(outerDecl, innerDecl) and
  not excludedViaNestedNamespaces(outerDecl, innerDecl) and
  varName = outerDecl.getName() and
  message = "Variable is hiding variable $@."
}
