/**
 * Provides a library with a `problems` predicate for the following issue:
 * Although scoped enum will implicitly define an underlying type of int, the underlying base type of enumeration should always be explicitly defined with a type that will be large enough to store all enumerators.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class EnumerationNotDefinedWithAnExplicitUnderlyingTypeSharedQuery extends Query { }

Query getQuery() { result instanceof EnumerationNotDefinedWithAnExplicitUnderlyingTypeSharedQuery }

query predicate problems(Enum e, string message) {
  not isExcluded(e, getQuery()) and
  not e.hasExplicitUnderlyingType() and
  message = "Base type of enumeration is not explicitly specified."
}
