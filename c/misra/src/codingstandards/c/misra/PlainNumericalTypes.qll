/** Provides the numeric-type detector shared by legacy and current directive wrappers. */

import cpp
import codingstandards.cpp.BuiltInNumericTypes

/** A numeric type covered by the legacy directive. */
private class NumericType extends BuiltInType {
  NumericType() {
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

/** A typedef name that encodes numeric width and signedness. */
private class SizedTypeName extends string {
  string pattern;
  int width;

  bindingset[this]
  pragma[inline]
  SizedTypeName() {
    pattern = "(u?int|c?float)(4|8|16|32|64|128)_t" and
    this.regexpMatch(pattern) and
    width = this.regexpCapture(pattern, 2).toInt()
  }

  /** Gets the width encoded by this name. */
  bindingset[this]
  pragma[inline]
  int getWidth() { result = width }

  /** Holds if this name denotes a complex type. */
  bindingset[this]
  pragma[inline]
  predicate isComplex() { this.charAt(0) = "c" }
}

/** Holds if `type` has an invalid complex name, with `message` explaining why. */
private predicate forbiddenComplexType(CTypedefType type, string message) {
  type.getName().(SizedTypeName).isComplex() and
  (
    if type.getBaseType().stripTopLevelSpecifiers() instanceof ComplexNumberType
    then
      type.getSize() * 8 != type.getName().(SizedTypeName).getWidth() * 2 and
      message = "The typedef type " + type.getName() + " does not have its indicated real size."
    else message = "The typedef type " + type.getName() + " is not a complex type."
  )
}

/** Holds if `type` has an invalid real name, with `message` explaining why. */
private predicate forbiddenRealType(CTypedefType type, string message) {
  not type.getName().(SizedTypeName).isComplex() and
  (
    if type.getBaseType().stripTopLevelSpecifiers() instanceof ComplexNumberType
    then message = "The typedef name " + type.getName() + " does not indicate a complex type."
    else (
      type.getSize() * 8 != type.getName().(SizedTypeName).getWidth() and
      message = "The typedef type " + type.getName() + " does not have its indicated size."
    )
  )
}

/** Holds if `type` is a forbidden alias, with `message` explaining why. */
private predicate forbiddenAlias(CTypedefType type, string message) {
  if type.getName() instanceof SizedTypeName
  then forbiddenRealType(type, message) or forbiddenComplexType(type, message)
  else (
    (
      type.getBaseType() instanceof NumericType
      or
      forbiddenAlias(type.getBaseType(), _)
    ) and
    message = "The type " + type.getName() + " is not an alias to a fixed-width numeric type."
  )
}

/** Holds if `element` violates the legacy directive, with `message` explaining why. */
predicate problems(Element element, string message) {
  exists(Variable variable | variable = element |
    variable.getType() instanceof NumericType and
    not variable instanceof ExcludedVariable and
    message = "The type " + variable.getType() + " is not a fixed-width numeric type."
  )
  or
  forbiddenAlias(element, message)
}

/** Holds if `element` declares or aliases a real or complex floating-point type. */
predicate hasFloatingType(Element element) {
  exists(Type type |
    type = element.(Variable).getType() or type = element.(CTypedefType).getBaseType()
  |
    type.stripType() instanceof FloatingPointType
    or
    type.stripType() instanceof ComplexNumberType
  )
}
