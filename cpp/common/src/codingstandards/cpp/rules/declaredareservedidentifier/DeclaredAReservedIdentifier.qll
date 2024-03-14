/**
 * Provides a library which includes a `problems` predicate for reporting declarations of reserved identifiers.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.ReservedNames

abstract class DeclaredAReservedIdentifierSharedQuery extends Query { }

Query getQuery() { result instanceof DeclaredAReservedIdentifierSharedQuery }

query predicate problems(Element m, string message) {
  not isExcluded(m, getQuery()) and
  ReservedNames::C11::isAReservedIdentifier(m, message)
}
