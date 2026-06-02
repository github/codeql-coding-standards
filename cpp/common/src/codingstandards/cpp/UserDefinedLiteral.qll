/**
 * A module to reason about user defined literals.
 */

import cpp

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

class UserDefinedLiteral extends Literal {
  UserDefinedLiteral() {
    exists(FunctionCall fc |
      this = fc.getArgument(0) and
      fc.getTarget() instanceof UserDefinedLiteralDeclaration
    )
  }
}
