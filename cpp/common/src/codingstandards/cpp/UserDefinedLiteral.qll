/**
 * A module to reason about user defined literals.
 */

import cpp

/**
 * A user defined literal operator is a function that defines the behavior of a user defined literal. 
 * It is declared using the `operator ""` syntax.
 * ```
 * constexpr long operator""_km(unsigned long value) {
 *   ...
 * }
 * ```
 */
class UserDefinedLiteralDeclaration extends Function {
  UserDefinedLiteralDeclaration() {
    // We use the '?' in this regexp because CodeQL CLI 2.4.6 and earlier reported these operators
    // using a single ", i.e `operator "`. This has been fixed in 2.5.9 (at the latest), but I
    // don't know if upgraded older databases will still have the broken version in. I've therefore
    // retained the ability to match on either `operator "` or `operator ""`
    this.getName().regexpMatch("operator \"\"?.*")
  }

  /** Holds if `this` has a compliant suffix. */
  predicate hasCompliantSuffix() { this.getName().regexpMatch("operator \"\"?_\\p{Alpha}+") }
}

/**
 * A user defined literal is a literal that is passed as an argument to a call to a user defined literal operator.
 * ```
 * 1000_km;
 * ```
 */
class UserDefinedLiteral extends Literal {
  UserDefinedLiteral() {
    exists(FunctionCall fc |
      this = fc.getArgument(0) and
      fc.getTarget() instanceof UserDefinedLiteralDeclaration
    )
  }
}
