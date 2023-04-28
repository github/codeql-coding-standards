/**
 * @id c/cert/do-not-confuse-narrow-and-wide-functions
 * @name STR38-C: Do not confuse narrow and wide character strings and functions
 * @description Mixing narrow and wide character strings may cause unpredictable program behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/str38-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

class NarrowCharStringType extends DerivedType {
  NarrowCharStringType() {
    // Use the transitive closure to include cv qualified character strings
    getBaseType+() instanceof CharType
    or
    // Use the transitive closure to include cv qualified character strings
    getBaseType+() instanceof Char8Type
  }
}

class WideCharStringType extends DerivedType {
  WideCharStringType() {
    // Use the transitive closure to include cv qualified character strings
    getBaseType+() instanceof Char16Type
    or
    // Use the transitive closure to include cv qualified character strings
    getBaseType+() instanceof Char32Type
    or
    // Use the transitive closure to include cv qualified character strings
    // `wchar_t` can be a typedef so we use the class `Wchar_t`
    getBaseType+() instanceof Wchar_t
  }
}

class WideToNarrowCast extends Cast {
  WideToNarrowCast() {
    this.getType() instanceof NarrowCharStringType and
    this.getExpr().getType() instanceof WideCharStringType
  }
}

class NarrowToWideCast extends Cast {
  NarrowToWideCast() {
    this.getType() instanceof WideCharStringType and
    this.getExpr().getType() instanceof NarrowCharStringType
  }
}

from FunctionCall call, Expr arg, Parameter p, Cast c, string actual, string expected
where
  exists(int i | call.getArgument(i) = arg and call.getTarget().getParameter(i) = p) and
  // Use the transitive closure to handle arrays that are converted to pointers before other type conversions.
  arg.getConversion+() = c and
  (
    c instanceof NarrowToWideCast and actual = "narrow" and expected = "wide"
    or
    c instanceof WideToNarrowCast and actual = "wide" and expected = "narrow"
  )
select call,
  "Call to function `" + call.getTarget().getName() + "` with a " + actual +
    " character string $@ where a " + expected + " character string is expected.", arg, "argument"
