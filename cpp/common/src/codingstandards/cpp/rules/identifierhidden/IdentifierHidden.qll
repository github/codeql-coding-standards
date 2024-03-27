/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Scope

abstract class IdentifierHiddenSharedQuery extends Query { }

Query getQuery() { result instanceof IdentifierHiddenSharedQuery }

query predicate problems(UserDeclaration v2, string message, UserDeclaration v1, string varName) {
  not isExcluded(v1, getQuery()) and
  not isExcluded(v2, getQuery()) and
  //ignore template variables for this rule
  not v1 instanceof TemplateVariable and
  not v2 instanceof TemplateVariable and
  //ignore types for this rule
  not v2 instanceof Type and
  not v1 instanceof Type and
  hidesStrict(v1, v2) and
  not excludedViaNestedNamespaces(v2, v1) and
  varName = v1.getName() and
  message = "Declaration is hiding declaration $@."
}
