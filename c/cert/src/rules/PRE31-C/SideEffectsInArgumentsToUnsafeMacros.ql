/**
 * @id c/cert/side-effects-in-arguments-to-unsafe-macros
 * @name PRE31-C: Avoid side effects in arguments to unsafe macros
 * @description Macro arguments can be expanded multiple times which can cause side-effects to be
 *              evaluated multiple times.
 * @kind problem
 * @precision low
 * @problem.severity error
 * @tags external/cert/id/pre31-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Macro
import codingstandards.cpp.SideEffect
import codingstandards.cpp.StructuralEquivalence
import codingstandards.cpp.sideeffect.DefaultEffects
import codingstandards.cpp.sideeffect.Customizations

class FunctionCallEffect extends GlobalSideEffect::Range {
  FunctionCallEffect() {
    exists(Function f |
      f = this.(FunctionCall).getTarget() and
      // Not a side-effecting function
      not f.(BuiltInFunction).getName() = "__builtin_expect" and
      // Not side-effecting functions
      not exists(string name |
        name =
          [
            "acos", "asin", "atan", "atan2", "ceil", "cos", "cosh", "exp", "fabs", "floor", "fmod",
            "frexp", "ldexp", "log", "log10", "modf", "pow", "sin", "sinh", "sqrt", "tan", "tanh",
            "cbrt", "erf", "erfc", "exp2", "expm1", "fdim", "fma", "fmax", "fmin", "hypot", "ilogb",
            "lgamma", "llrint", "llround", "log1p", "log2", "logb", "lrint", "lround", "nan",
            "nearbyint", "nextafter", "nexttoward", "remainder", "remquo", "rint", "round",
            "scalbln", "scalbn", "tgamma", "trunc"
          ] and
        f.hasGlobalOrStdName([name, name + "f", name + "l"])
      )
    )
  }
}

class CrementEffect extends LocalSideEffect::Range {
  CrementEffect() { this instanceof CrementOperation }
}

/**
 * A macro that is considered potentially "unsafe" because one or more arguments are expanded
 * multiple times.
 */
class UnsafeMacro extends FunctionLikeMacro {
  int unsafeArgumentIndex;

  UnsafeMacro() {
    exists(this.getAParameterUse(unsafeArgumentIndex)) and
    // Only consider arguments that are expanded multiple times, and do not consider "stringified" arguments
    count(int indexInBody |
      indexInBody = this.getAParameterUse(unsafeArgumentIndex) and
      not this.getBody().charAt(indexInBody) = "#"
    ) > 1
  }

  int getAnUnsafeArgumentIndex() { result = unsafeArgumentIndex }
}

from
  UnsafeMacro flm, MacroInvocation mi, Expr e, SideEffect sideEffect, int i, string arg,
  string sideEffectDesc
where
  not isExcluded(e, SideEffects4Package::sideEffectsInArgumentsToUnsafeMacrosQuery()) and
  sideEffect = getASideEffect(e) and
  flm.getAnInvocation() = mi and
  not exists(mi.getParentInvocation()) and
  mi.getAnExpandedElement() = e and
  i = flm.getAnUnsafeArgumentIndex() and
  arg = mi.getExpandedArgument(i) and
  (
    sideEffect instanceof CrementEffect and
    exists(arg.indexOf(sideEffect.(CrementOperation).getOperator())) and
    sideEffectDesc = "the use of the " + sideEffect.(CrementOperation).getOperator() + " operator"
    or
    sideEffect instanceof FunctionCallEffect and
    exists(arg.indexOf(sideEffect.(FunctionCall).getTarget().getName() + "(")) and
    sideEffectDesc =
      "a call to the function '" + sideEffect.(FunctionCall).getTarget().getName() + "'"
  )
select sideEffect,
  "Argument " + mi.getUnexpandedArgument(i) + " to unsafe macro '" + flm.getName() +
    "' is expanded to '" + arg + "' multiple times and includes " + sideEffectDesc +
    " as a side-effect."
