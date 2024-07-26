/**
 * Provides a library with a `problems` predicate for the following issue:
 * Omission of type specifiers may not be supported by some compilers.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Identifiers

abstract class TypeOmittedSharedQuery extends Query { }

Query getQuery() { result instanceof TypeOmittedSharedQuery }

query predicate problems(Declaration d, string message) {
  not isExcluded(d, getQuery()) and
  isDeclaredImplicit(d) and
  message = "Declaration " + d.getName() + " is missing a type specifier."
}
