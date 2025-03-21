import cpp

newtype TIdentifierLinkage =
  TIdentifierLinkageExternal() or
  TIdentifierLinkageInternal() or
  TIdentifierLinkageNone()

/**
 * In C, identifiers have internal linkage, or external linkage, or no linkage (6.2.2.1).
 *
 * The linkage of an identifier is used to, among other things, determine the storage duration
 * and/or lifetime of that identifier. Storage durations and lifetimes are often used to define
 * rules in the various coding standards.
 */
class IdentifierLinkage extends TIdentifierLinkage {
  predicate isExternal() { this = TIdentifierLinkageExternal() }

  predicate isInternal() { this = TIdentifierLinkageInternal() }

  predicate isNone() { this = TIdentifierLinkageNone() }

  string toString() {
    this.isExternal() and result = "external linkage"
    or
    this.isInternal() and result = "internal linkage"
    or
    this.isNone() and result = "no linkage"
  }
}

/**
 * Determine the linkage of a variable: external, or static, or none.
 *
 * The linkage of a variable is determined by its scope and storage class. Note that other types of
 * identifiers (e.g. functions) may also have linkage, but that behavior is not covered in this
 * predicate.
 */
IdentifierLinkage linkageOfVariable(Variable v) {
  // 6.2.2.3, file scope identifiers marked static have internal linkage.
  v.isTopLevel() and v.isStatic() and result.isInternal()
  or
  // 6.2.2.4 describes generally non-static file scope identifiers, which have external linkage.
  v.isTopLevel() and not v.isStatic() and result.isExternal()
  or
  // Note: Not all identifiers have linkage, see 6.2.2.6
  not v.isTopLevel() and result.isNone()
}
