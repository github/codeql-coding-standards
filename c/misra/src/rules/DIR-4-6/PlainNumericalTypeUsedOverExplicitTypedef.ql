/**
 * @id c/misra/plain-numerical-type-used-over-explicit-typedef
 * @name DIR-4-6: Do not use plain numerical types over typedefs named after their explicit bit layout
 * @description Using plain numerical types over typedefs with explicit sign and bit counts may lead
 *              to confusion on how much bits are allocated for a value.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/dir-4-6
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.BuiltInNumericTypes

class BuiltInNumericType extends BuiltInType {
  BuiltInNumericType() {
    /* Exclude the plain char because it does not count as a numeric type */
    this.(CharType).isExplicitlySigned()
    or
    this.(CharType).isExplicitlyUnsigned()
    or
    this instanceof BuiltInIntegerType
    or
    this instanceof FloatType
    or
    this instanceof DoubleType
    or
    this instanceof LongDoubleType
  }
}

predicate forbiddenBuiltinNumericUsedInDecl(Variable var, string message) {
  var.getType() instanceof BuiltInNumericType and
  not var instanceof ExcludedVariable and
  message = "The type " + var.getType() + " is not a fixed-width numeric type."
}

predicate forbiddenTypedef(TypedefType typedef, string message) {
  typedef.getBaseType() instanceof BuiltInNumericType and
  not typedef.getName().regexpMatch("u?(int|float)(4|8|16|32|64|128)_t") and
  message = "The type " + typedef.getName() + " is not an alias to a fixed-width numeric type."
}

from Element elem, string message
where
  not isExcluded(elem, Types1Package::plainNumericalTypeUsedOverExplicitTypedefQuery()) and
  (
    forbiddenBuiltinNumericUsedInDecl(elem, message) or
    forbiddenTypedef(elem, message)
  )
select elem, message
