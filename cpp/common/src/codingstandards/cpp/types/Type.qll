/**
 * A module for representing different `Type`s.
 */

import cpp

/**
 * A fundamental type, as defined by `[basic.fundamental]`.
 */
class FundamentalType extends BuiltInType {
  FundamentalType() {
    // A fundamental type is any `BuiltInType` except types indicating errors during extraction, or
    // "unknown" types inserted into uninstantiated templates
    not this instanceof ErroneousType and
    not this instanceof UnknownType
  }
}

/**
 * A type that is incomplete.
 */
class IncompleteType extends Class {
  IncompleteType() { not hasDefinition() }
}

/**
 * A type that implements the BitmaskType trait.
 * https://en.cppreference.com/w/cpp/named_req/BitmaskType
 */
abstract class BitmaskType extends Type { }

/**
 * Holds if `enum` implements required overload `overload` to implement
 * the BitmaskType trait.
 */
private predicate isRequiredEnumOverload(Enum enum, Function overload) {
  overload.getName().regexpMatch("operator([&|^~]|&=|\\|=)") and
  forex(Parameter p | p = overload.getAParameter() |
    (
      p.getType() = enum
      or
      p.getType().(ReferenceType).getBaseType() = enum
    )
  )
}

private class EnumBitmaskType extends BitmaskType, Enum {
  EnumBitmaskType() {
    // Implements all the required overload
    count(Function overload | isRequiredEnumOverload(this, overload)) = 6
  }
}

/**
 * A type without `const` and `volatile` specifiers.
 */
Type stripSpecifiers(Type type) {
  if type instanceof SpecifiedType
  then result = stripSpecifiers(type.(SpecifiedType).getBaseType())
  else result = type
}

signature class PossiblySpecifiedBaseType extends Type;

/**
 * This module defines a class `Type` which holds for types `T` and `const/volatile T` etc.
 *
 * Similar to `getUnspecifiedType()`, but does not resolve typedefs. Useful for matching
 * potentially qualified versions of standard typedef types, such as `const mtx_t`.
 *
 * Example usage: `someType.(PossiblySpecified<PointerType>::Type).strip()`
 */
module PossiblySpecified<PossiblySpecifiedBaseType BaseType> {
  import cpp as cpp

  final class CppType = cpp::Type;

  class Type extends CppType {
    BaseType baseType;

    Type() { baseType = stripSpecifiers(this) }

    BaseType strip() { result = baseType }
  }
}

/**
 * Get the precision of an integral type, where precision is defined as the number of bits
 * that can be used to represent the numeric value.
 * https://wiki.sei.cmu.edu/confluence/display/c/INT35-C.+Use+correct+integer+precisions
 */
int getPrecision(IntegralType type) {
  type.isExplicitlyUnsigned() and result = type.getSize() * 8
  or
  type.isExplicitlySigned() and result = type.getSize() * 8 - 1
}
