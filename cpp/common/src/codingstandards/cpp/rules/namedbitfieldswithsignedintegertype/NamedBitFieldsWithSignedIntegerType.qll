/**
 * Provides a library with a `problems` predicate for the following issue:
 * A named bit-field with signed integer type shall not have a length of one bit.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class NamedBitFieldsWithSignedIntegerTypeSharedQuery extends Query { }

Query getQuery() { result instanceof NamedBitFieldsWithSignedIntegerTypeSharedQuery }

query predicate problems(BitField bitField, string message) {
  not isExcluded(bitField, getQuery()) and
  bitField.getDeclaredNumBits() = 1 and // Single-bit,
  not bitField.isAnonymous() and // named,
  bitField.getType().(IntegralType).isSigned() and // but its type is signed.
  message = "A named bit-field with signed integral type should have at least 2 bits of storage."
}
