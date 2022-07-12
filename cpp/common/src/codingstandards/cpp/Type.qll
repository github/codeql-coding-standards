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
