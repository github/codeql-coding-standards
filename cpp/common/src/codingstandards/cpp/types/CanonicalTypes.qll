import cpp

/**
 * One of the 10 canonical integer types, which are the standard integer types.
 */
class CanonicalIntegralType extends IntegralType {
  CanonicalIntegralType() { this = this.getCanonicalArithmeticType() }

  /**
   * Holds if this is the canonical integer type with the shortest name for its size.
   */
  predicate isMinimal() {
    not exists(CanonicalIntegralType other |
      other.getSize() = this.getSize() and
      (
        other.isSigned() and this.isSigned()
        or
        other.isUnsigned() and this.isUnsigned()
      ) and
      other.getName().length() < this.getName().length()
    )
  }
}
