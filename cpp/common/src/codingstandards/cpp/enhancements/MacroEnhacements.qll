/**
 * Enhancements to the handling of `Macro`s in the standard library.
 */
module MacroEnhancements {
  import cpp as StandardLibrary

  /**
   * A version of `MacroInvocation` that includes all potentially affected elements.
   *
   * This is a workaround for a standard library bug, where macro expansions in initializers did not
   * have any affected elements. For example, for:
   * ```
   * int x = NULL;
   * ```
   * There was a `MacroInvocation` at that location, but `getAnAffectedElement()` reported no
   * elements. This is because the class uses the `inmacroexpansion` and `macrolocationbind`
   * relations to determine "affected" elements, but the initializer only produces an entry in the
   * `affectedbymacroexpansion` relation. This class overrides the default `getAnAffectedElement()`
   * member predicate to also include elements referenced by `affectedbymacroexpansion`.
   */
  class MacroInvocation extends StandardLibrary::MacroInvocation {
    override StandardLibrary::Locatable getAnExpandedElement() {
      result = super.getAnExpandedElement() or
      affectedbymacroexpansion(StandardLibrary::unresolveElement(result),
        StandardLibrary::underlyingElement(this))
    }
  }

  /** A use of the NULL macro. */
  class NULL extends StandardLibrary::Literal {
    NULL() {
      exists(StandardLibrary::NullMacro nm | this = nm.getAnInvocation().getAnExpandedElement())
    }
  }
}
