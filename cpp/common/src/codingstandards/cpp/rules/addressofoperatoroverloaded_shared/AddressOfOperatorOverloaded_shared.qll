/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Operator

abstract class AddressOfOperatorOverloaded_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof AddressOfOperatorOverloaded_sharedSharedQuery }

query predicate problems(UnaryAddressOfOperator e, string message) {
not isExcluded(e, getQuery()) and message = "The unary & operator overloaded."
}