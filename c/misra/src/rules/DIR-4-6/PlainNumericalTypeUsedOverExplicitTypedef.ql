/**
 * @id c/misra/plain-numerical-type-used-over-explicit-typedef
 * @name DIR-4-6: Do not use plain numerical types over typedefs named after their explicit bit layout
 * @description Using plain numerical types over typedefs with explicit sign and bit counts may lead
 *              to confusion on how much bits are allocated for a value.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/dir-4-6
 *       external/misra/c/2012/third-edition-first-revision
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
    or
    this instanceof ComplexNumberType
  }
}

predicate forbiddenBuiltinNumericUsedInDecl(Variable var, string message) {
  var.getType() instanceof BuiltInNumericType and
  not var instanceof ExcludedVariable and
  message = "The type " + var.getType() + " is not a fixed-width numeric type."
}

class SizedTypeString extends string {
  string pattern;
  int size;

  bindingset[this]
  pragma[inline]
  SizedTypeString() {
    pattern = "(u?int|c?float)(4|8|16|32|64|128)_t" and
    this.regexpMatch(pattern) and
    size = this.regexpCapture(pattern, 2).toInt()
  }

  bindingset[this]
  pragma[inline]
  int getSize() { result = size }

  bindingset[this]
  pragma[inline]
  predicate isComplex() { this.charAt(0) = "c" }
}

predicate forbiddenComplexType(CTypedefType typedef, string message) {
  typedef.getName().(SizedTypeString).isComplex() and
  (
    if typedef.getBaseType().stripTopLevelSpecifiers() instanceof ComplexNumberType
    then
      typedef.getSize() * 8 != typedef.getName().(SizedTypeString).getSize() * 2 and
      message = "The typedef type " + typedef.getName() + " does not have its indicated real size."
    else message = "The typedef type " + typedef.getName() + " is not a complex type."
  )
}

predicate forbiddenRealType(CTypedefType typedef, string message) {
  not typedef.getName().(SizedTypeString).isComplex() and
  (
    if typedef.getBaseType().stripTopLevelSpecifiers() instanceof ComplexNumberType
    then message = "The typedef name " + typedef.getName() + " does not indicate a complex type."
    else (
      typedef.getSize() * 8 != typedef.getName().(SizedTypeString).getSize() and
      message = "The typedef type " + typedef.getName() + " does not have its indicated size."
    )
  )
}

predicate forbiddenTypedef(CTypedefType typedef, string message) {
  /* If the typedef's name contains an explicit size */
  (
    if typedef.getName() instanceof SizedTypeString
    then (
      forbiddenRealType(typedef, message)
      or
      forbiddenComplexType(typedef, message)
    ) else (
      (
        // type def is to a built in numeric type
        typedef.getBaseType() instanceof BuiltInNumericType and
        // but does not include the size in the name
        not typedef.getName() instanceof SizedTypeString
        or
        // this is a typedef to a forbidden type def
        forbiddenTypedef(typedef.getBaseType(), _)
      ) and
      message = "The type " + typedef.getName() + " is not an alias to a fixed-width numeric type."
    )
  )
}

from Element elem, string message
where
  not isExcluded(elem, Types1Package::plainNumericalTypeUsedOverExplicitTypedefQuery()) and
  (
    forbiddenBuiltinNumericUsedInDecl(elem, message) or
    forbiddenTypedef(elem, message)
  )
select elem, message
