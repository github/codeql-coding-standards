/**
 * Provides a library with a `problems` predicate for the following issue:
 * The address-of operator shall not be overloaded.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Operator

abstract class AddressOfOperatorOverloadedSharedQuery extends Query { }

Query getQuery() { result instanceof AddressOfOperatorOverloadedSharedQuery }

query predicate problems(UnaryAddressOfOperator e, string message) {
  not isExcluded(e, getQuery()) and message = "The unary & operator overloaded."
}
