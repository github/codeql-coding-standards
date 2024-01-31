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

/** A type that implements the BitmaskType trait.
 * https://en.cppreference.com/w/cpp/named_req/BitmaskType
 *
*/
abstract class BitmaskType extends Type { }

/** Holds if `enum` implements required overload `overload` to implement
 * the BitmaskType trait.
*/
private predicate isRequiredEnumOverload(Enum enum, Function overload) {
      overload.getName().regexpMatch("operator([&|^~]|&=|\\|=)")
    and
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