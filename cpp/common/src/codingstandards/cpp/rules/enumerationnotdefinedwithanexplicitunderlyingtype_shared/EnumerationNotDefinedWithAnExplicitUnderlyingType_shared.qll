/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class EnumerationNotDefinedWithAnExplicitUnderlyingType_sharedSharedQuery extends Query { }

Query getQuery() {
  result instanceof EnumerationNotDefinedWithAnExplicitUnderlyingType_sharedSharedQuery
}

query predicate problems(Enum e, string message) {
  not isExcluded(e, getQuery()) and
  not e.hasExplicitUnderlyingType() and
  message = "Base type of enumeration is not explicitly specified."
}
