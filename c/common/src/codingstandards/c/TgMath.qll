import cpp

private string getATgMathMacroName(boolean allowComplex, int numberOfParameters) {
  allowComplex = true and
  numberOfParameters = 1 and
  result =
    [
      "acos", "acosh", "asin", "asinh", "atan", "atanh", "carg", "cimag", "conj", "cos", "cosh",
      "cproj", "creal", "exp", "fabs", "log", "sin", "sinh", "sqrt", "tan", "tanh"
    ]
  or
  allowComplex = true and
  numberOfParameters = 2 and
  result = "pow"
  or
  allowComplex = false and
  numberOfParameters = 1 and
  result =
    [
      "cbrt", "ceil", "erf", "erfc", "exp2", "expm1", "floor", "ilogb", "lgamma", "llrint",
      "llround", "log10", "log1p", "log2", "logb", "lrint", "lround", "nearbyint", "rint", "round",
      "tgamma", "trunc",
    ]
  or
  allowComplex = false and
  numberOfParameters = 2 and
  result =
    [
      "atan2", "copysign", "fdim", "fmax", "fmin", "fmod", "frexp", "hypot", "ldexp", "nextafter",
      "nexttoward", "remainder", "scalbn", "scalbln"
    ]
  or
  allowComplex = false and
  numberOfParameters = 3 and
  result = ["fma", "remquo"]
}

private predicate hasOutputArgument(string macroName, int index) {
  macroName = "frexp" and index = 1
  or
  macroName = "remquo" and index = 2
}

class TgMathInvocation extends MacroInvocation {
  Call call;
  boolean allowComplex;
  int numberOfParameters;

  TgMathInvocation() {
    this.getMacro().getName() = getATgMathMacroName(allowComplex, numberOfParameters) and
    call = getBestCallInExpansion(this)
  }

  /** Account for extra parameters added by gcc */
  private int getParameterOffset() {
    // Gcc calls look something like: `__builtin_tgmath(cosf, cosd, cosl, arg)`, in this example
    // there is a parameter offset of 3, so `getOperandArgument(0)` is equivalent to
    // `call.getArgument(3)`.
    result = call.getNumberOfArguments() - numberOfParameters
  }

  Expr getOperandArgument(int i) {
    i >= 0 and
    result = call.getArgument(i + getParameterOffset()) and
    //i in [0..numberOfParameters - 1] and
    not hasOutputArgument(getMacro().getName(), i)
  }

  /** Get all explicit conversions, except those added by clang in the macro body */
  Expr getExplicitlyConvertedOperandArgument(int i) {
    exists(Expr explicitConv |
      explicitConv = getOperandArgument(i).getExplicitlyConverted() and
      // clang explicitly casts most arguments, but not some integer arguments such as in `scalbn`.
      if call.getTarget().getName().matches("__tg_%") and explicitConv instanceof Conversion
      then result = explicitConv.(Conversion).getExpr()
      else result = explicitConv
    )
  }

  int getNumberOfOperandArguments() {
    result = numberOfParameters - count(int i | hasOutputArgument(getMacroName(), i))
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
