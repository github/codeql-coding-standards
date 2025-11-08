/**
 * Provides a library for managing how alerts are reported.
 */

import cpp

signature class ResultType extends Element;

/**
 * A module for unwrapping results that occur in macro expansions.
 */
module MacroUnwrapper<ResultType ResultElement> {
  /**
   * Gets a macro invocation that applies to the result element.
   */
  private MacroInvocation getAMacroInvocation(ResultElement re) {
    result.getAnAffectedElement() = re
  }

  private MacroInvocation getASubsumedMacroInvocation(ResultElement re) {
    result = getAMacroInvocation(re) and
    // Only report cases where the element is not located at the macro expansion site
    // This means we'll report results in macro arguments in the macro argument
    // location, not within the macro itself.
    //
    // Do not join start column values.
    pragma[only_bind_out](result.getLocation().getStartColumn()) =
      pragma[only_bind_out](re.getLocation().getStartColumn())
  }

  /**
   * Gets the primary macro invocation that generated the result element.
   *
   * Does not hold for cases where the result element is located at a macro argument site.
   */
  MacroInvocation getPrimaryMacroInvocation(ResultElement re) {
    exists(MacroInvocation mi |
      mi = getASubsumedMacroInvocation(re) and
      // No other more specific macro that expands to element
      not exists(MacroInvocation otherMi |
        otherMi = getAMacroInvocation(re) and otherMi.getParentInvocation() = mi
      ) and
      result = mi
    )
  }

  /**
   * Gets the primary macro that generated the result element.
   */
  Macro getPrimaryMacro(ResultElement re) { result = getPrimaryMacroInvocation(re).getMacro() }

  /**
   * If a result element is expanded from a macro invocation, then return the "primary" macro that
   * generated the element, otherwise return the element itself.
   */
  Element unwrapElement(ResultElement re) {
    if exists(getPrimaryMacro(re)) then result = getPrimaryMacro(re) else result = re
  }

  /* Final class so we can extend it */
  final private class FinalMacroInvocation = MacroInvocation;

  /* A macro invocation that expands to create a `ResultElement` */
  class ResultMacroExpansion extends FinalMacroInvocation {
    ResultElement re;

    ResultMacroExpansion() { re = getAnExpandedElement() }

    ResultElement getResultElement() { result = re }
  }

  /* The most specific macro invocation that expands to create this `ResultElement`. */
  class PrimaryMacroExpansion extends ResultMacroExpansion {
    PrimaryMacroExpansion() { this = getPrimaryMacroInvocation(re) }
  }
}
