/**
 * Provides a library with a `problems` predicate for the following issue:
 * A bit-field shall have an appropriate type.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Compiler

abstract class BitFieldShallHaveAnAppropriateTypeSharedQuery extends Query { }

Query getQuery() { result instanceof BitFieldShallHaveAnAppropriateTypeSharedQuery }

Type getSupportedBitFieldType(Compiler compiler) {
  compiler instanceof UnsupportedCompiler and
  (
    result instanceof IntType and
    (
      result.(IntegralType).isExplicitlySigned() or
      result.(IntegralType).isExplicitlyUnsigned()
    )
    or
    result instanceof BoolType
  )
  or
  (compiler instanceof Gcc or compiler instanceof Clang) and
  (
    result instanceof IntegralOrEnumType
    or
    result instanceof BoolType
  )
}

query predicate problems(BitField bitField, string message) {
  not isExcluded(bitField, getQuery()) and
  /* A violation would neither be an appropriate primitive type nor an appropriate typedef. */
  not getSupportedBitFieldType(getCompiler(bitField.getFile())) =
    bitField.getType().resolveTypedefs() and
  message = "Bit-field '" + bitField + "' is declared on type '" + bitField.getType() + "'."
}
