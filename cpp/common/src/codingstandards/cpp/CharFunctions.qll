import cpp

private string getCToOrIsName() {
  result =
    [
      "isalnum", "isalpha", "isascii", "isblank", "iscntrl", "isdigit", "isgraph", "islower",
      "isprint", "ispunct", "isspace", "isupper", "isxdigit", "__isspace", "toascii", "toupper",
      "tolower"
    ]
}

/**
 * A use of one of the APIs in the `<ctype.h>` header that test or convert characters.
 *
 * Note: these operations are commonly implemented as either function or a macro. This class
 * abstracts away from those details, providing a `getConvertedArgument` predicate to get the
 * argument after any conversions specified by the user, excluding any conversions induced by
 * the structure of the macro, or
 */
abstract class UseOfToOrIsChar extends Element {
  abstract Expr getConvertedArgument();
}

private class CToOrIsCharFunctionCall extends FunctionCall, UseOfToOrIsChar {
  CToOrIsCharFunctionCall() {
    getTarget().getName() = getCToOrIsName() and
    // Some library implementations, such as musl, include a "dead" call to the same function
    // that has also been implemented as a macro, in order to retain the right types. We exclude
    // this call because it does not appear in the control flow or data flow graph. However,
    // isspace directly calls __isspace, which is allowed
    (
      getTarget().getName() = "__isspace" or
      not any(CToOrIsCharMacroInvocation mi).getAnExpandedElement() = this
    )
  }

  override Expr getConvertedArgument() { result = getArgument(0).getExplicitlyConverted() }
}

private class CToOrIsCharMacroInvocation extends MacroInvocation, UseOfToOrIsChar {
  CToOrIsCharMacroInvocation() { getMacroName() = getCToOrIsName() }

  override Expr getConvertedArgument() {
    /*
     * There is no common approach to how the macros are defined, so we handle
     * each compiler/library case individually. Fortunately, there's no conflict
     * between different compilers.
     */

    // For the "is" APIs, if clang and gcc use a macro, then it expands to an
    // array access on the left hand side of an &
    exists(ArrayExpr ae | ae = getExpr().(BitwiseAndExpr).getLeftOperand() |
      // Casted to an explicit (int), so we want unwind only a single conversion
      result = ae.getArrayOffset().getFullyConverted().(Conversion).getExpr()
    )
    or
    // For the "toupper/tolower" APIs, QNX expands to an array access
    exists(ArrayExpr ae |
      ae = getExpr() and
      result = ae.getArrayOffset().getFullyConverted().(Conversion).getExpr()
    )
    or
    // For the tolower/toupper cases, a secondary macro is expanded
    exists(MacroInvocation mi |
      mi.getParentInvocation() = this and
      mi.getMacroName() = "__tobody"
    |
      /*
       * tolower and toupper can be defined by macros which:
       * - if the size of the type is greater than 1
       *   - then check if it's a compile time constant
       *     - then use c < -128 || c > 255 ? c : (a)[c]
       *     - else call the function
       *   - else (a)[c]
       */

      exists(ArrayExpr ae |
        ae = mi.getAnExpandedElement() and
        result = ae.getArrayOffset() and
        // There are two array access, but only one should be reachable
        result.getBasicBlock().isReachable()
      )
      or
      exists(ConditionalExpr ce |
        ce = mi.getAnExpandedElement() and
        result = ce.getThen() and
        result.getBasicBlock().isReachable()
      )
    )
    or
    // musl uses a conditional expression as the expansion
    exists(ConditionalExpr ce | ce = getExpr() |
      // for most macro expansions, the else is a subtraction inside a `<`
      exists(SubExpr s |
        not getMacroName() = "isalpha" and
        s = ce.getElse().(LTExpr).getLeftOperand() and
        // Casted to an explicit (int), so we want unwind only a single conversion
        result = s.getLeftOperand().getFullyConverted().(Conversion).getExpr()
      )
      or
      // for isalpha, the else is a bitwise or inside a subtraction inside a `<`
      exists(BitwiseOrExpr bo |
        // Casted to an explicit (unsigned)
        getMacroName() = "isalpha" and
        bo = ce.getElse().(LTExpr).getLeftOperand().(SubExpr).getLeftOperand() and
        // Casted to an explicit (int), so we want unwind only a single conversion
        result =
          bo.getLeftOperand().getFullyConverted().(Conversion).getExpr().(ParenthesisExpr).getExpr()
      )
    )
  }
}
