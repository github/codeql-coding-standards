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

abstract class ForbiddenType extends Type { }

class BuiltinNumericType extends ForbiddenType {
  BuiltinNumericType() {
    /* Exclude the plain char because it does not count as a numeric type */
    this.(CharType).isExplicitlySigned()
    or
    this.(CharType).isExplicitlyUnsigned()
    or
    this instanceof ShortType
    or
    this instanceof IntType
    or
    this instanceof LongType
    or
    this instanceof LongLongType
    or
    this instanceof FloatType
    or
    this instanceof DoubleType
    or
    this instanceof LongDoubleType
  }
}

class ForbiddenTypedefType extends ForbiddenType, TypedefType {
  ForbiddenTypedefType() {
    this.(TypedefType).getBaseType() instanceof BuiltinNumericType and
    not this.getName().regexpMatch("u?(int|float)(4|8|16|32|64|128)_t")
  }
}

/* TODO: BuiltinNumericType not being flagged */
from ForbiddenType forbiddenType
where not isExcluded(forbiddenType, TypesPackage::plainNumericalTypeUsedOverExplicitTypedefQuery())
select forbiddenType,
  "The type " + forbiddenType + " is not a fixed-width numeric type nor an alias to one."
