/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class NamedBitFieldsWithSignedIntegerType_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof NamedBitFieldsWithSignedIntegerType_sharedSharedQuery }

query predicate problems(BitField bitField, string message) {
  not isExcluded(bitField, getQuery()) and
  bitField.getDeclaredNumBits() = 1 and // Single-bit,
  not bitField.isAnonymous() and // named,
  bitField.getType().(IntegralType).isSigned() and // but its type is signed.
  message = "A named bit-field with signed integral type should have at least 2 bits of storage."
}
