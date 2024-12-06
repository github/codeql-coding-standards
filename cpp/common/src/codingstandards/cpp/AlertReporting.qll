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
    result.getAnExpandedElement() = re
  }

  /**
   * Gets the primary macro invocation that generated the result element.
   */
  MacroInvocation getPrimaryMacroInvocation(ResultElement re) {
    exists(MacroInvocation mi |
      mi = getAMacroInvocation(re) and
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
