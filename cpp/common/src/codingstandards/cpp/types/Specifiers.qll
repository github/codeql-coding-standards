import cpp

class ConstSpecifier extends Specifier {
  ConstSpecifier() { this.hasName("const") }
}

/**
 * A SpecifiedType with a `const` specifier.
 *
 * Note that this does *not* find all const types, as it does not resolve typedefs etc.
 */
class RawConstType extends SpecifiedType {
  RawConstType() { this.getASpecifier() instanceof ConstSpecifier }
}

/**
 * Any type that is const, using the `.isConst()` member predicate.
 */
class ConstType extends Type {
  ConstType() { this.isConst() }
}

/**
 * Any type that is not const, using the `.isConst()` member predicate.
 */
class NonConstType extends Type {
  NonConstType() { not this.isConst() }
}
