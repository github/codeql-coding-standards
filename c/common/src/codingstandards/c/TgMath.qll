import cpp

private string getATgMathMacroName(boolean allowComplex) {
  allowComplex = true and
  result =
    [
      "acos", "acosh", "asin", "asinh", "atan", "atanh", "carg", "cimag", "conj", "cos", "cosh",
      "cproj", "creal", "exp", "fabs", "log", "pow", "sin", "sinh", "sqrt", "tan", "tanh"
    ]
  or
  allowComplex = false and
  result =
    [
      "atan2", "cbrt", "ceil", "copysign", "erf", "erfc", "exp2", "expm1", "fdim", "floor", "fma",
      "fmax", "fmin", "fmod", "frexp", "hypot", "ilogb", "ldexp", "lgamma", "llrint", "llround",
      "log10", "log1p", "log2", "logb", "lrint", "lround", "nearbyint", "nextafter", "nexttoward",
      "remainder", "remquo", "rint", "round", "scalbn", "scalbln", "tgamma", "trunc",
    ]
}

private predicate hasOutputArgument(string macroName, int index) {
  macroName = "frexp" and index = 1
  or
  macroName = "remquo" and index = 2
}

class TgMathInvocation extends MacroInvocation {
  Call call;
  boolean allowComplex;

  TgMathInvocation() {
    this.getMacro().getName() = getATgMathMacroName(allowComplex) and
    call = getBestCallInExpansion(this)
  }

  Expr getOperandArgument(int i) {
    result = call.getArgument(i) and
    not hasOutputArgument(call.getTarget().getName(), i)
  }

  int getNumberOfOperandArguments() {
    result = call.getNumberOfArguments() - count(int i | hasOutputArgument(getMacroName(), i))
  }

  Expr getAnOperandArgument() { result = getOperandArgument(_) }

  predicate allowsComplex() { allowComplex = true }
}

private Call getACallInExpansion(MacroInvocation mi) { result = mi.getAnExpandedElement() }

private Call getNameMatchedCallInExpansion(MacroInvocation mi) {
  result = getACallInExpansion(mi) and result.getTarget().getName() = mi.getMacroName()
}

private Call getBestCallInExpansion(MacroInvocation mi) {
  count(getACallInExpansion(mi)) = 1 and result = getACallInExpansion(mi)
  or
  count(getNameMatchedCallInExpansion(mi)) = 1 and result = getNameMatchedCallInExpansion(mi)
  or
  count(getNameMatchedCallInExpansion(mi)) > 1 and
  result = rank[1](Call c | c = getACallInExpansion(mi) | c order by c.getTarget().getName())
}
