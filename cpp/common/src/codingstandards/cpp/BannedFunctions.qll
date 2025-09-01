/**
 * A library for supporting the consistent detection of banned functions in C++ code.
 */

import cpp
import AlertReporting

/**
 * A signature for a banned function.
 */
signature class BannedFunction extends Function;

/**
 * A module for detecting uses of banned functions in C++ code.
 */
module BannedFunctions<BannedFunction F> {
  final private class FinalExpr = Expr;

  /**
   * An expression that uses a banned function.
   *
   * It can be either a function call or a function access (taking the address of the function).
   */
  class UseExpr extends FinalExpr {
    string action;
    F bannedFunction;

    UseExpr() {
      this.(FunctionCall).getTarget() = bannedFunction and
      action = "Call to"
      or
      this.(FunctionAccess).getTarget() = bannedFunction and
      action = "Address taken for"
    }

    string getFunctionName() { result = bannedFunction.getName() }

    string getAction() { result = action }

    Element getPrimaryElement() {
      // If this is defined in a macro in the users source location, then report the macro
      // expansion, otherwise report the element itself. This ensures that we always report
      // the use of the terminating function, but combine usages when the macro is defined
      // by the user.
      exists(Element e | e = MacroUnwrapper<UseExpr>::unwrapElement(this) |
        if exists(e.getFile().getRelativePath()) then result = e else result = this
      )
    }
  }

  final private class FinalElement = Element;

  /**
   * A `Use` of a banned function.
   *
   * This is an `Element` in a program which represents the use of a banned function.
   * For uses within macro expansions, this may report the location of the macro, if
   * it is defined within the user's source code.
   */
  class Use extends FinalElement {
    UseExpr use;

    Use() { this = use.getPrimaryElement() }

    string getFunctionName() { result = use.getFunctionName() }

    string getAction() { result = use.getAction() }
  }
}
