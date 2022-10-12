/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Scope

abstract class IdentifierHiddenSharedQuery extends Query { }

Query getQuery() { result instanceof IdentifierHiddenSharedQuery }

query predicate problems(UserVariable v2, string message, UserVariable v1, string varName) {
  not isExcluded(v1, getQuery()) and
  not isExcluded(v2, getQuery()) and
  hides(v1, v2) and
  varName = v1.getName() and
  message = "Variable is hiding variable $@."
}
