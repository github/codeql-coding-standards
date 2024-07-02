/**
 * Provides a library which includes a `problems` predicate for reporting unchecked range, domain and pole errors.
 */

import cpp
import codingstandards.cpp.CodingStandards
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

abstract class UncheckedRangeDomainPoleErrorsSharedQuery extends Query { }

Query getQuery() { result instanceof UncheckedRangeDomainPoleErrorsSharedQuery }

bindingset[name]
Function getMathVariants(string name) { result.hasGlobalOrStdName([name, name + "f", name + "l"]) }

predicate hasDomainError(FunctionCall fc, string description) {
  exists(Function functionWithDomainError | fc.getTarget() = functionWithDomainError |
    functionWithDomainError = [getMathVariants(["acos", "asin", "atanh"])] and
    not (
      upperBound(fc.getArgument(0)) <= 1.0 and
      lowerBound(fc.getArgument(0)) >= -1.0
    ) and
    description =
      "the argument has a range " + lowerBound(fc.getArgument(0)) + "..." +
        upperBound(fc.getArgument(0)) + " which is outside the domain of this function (-1.0...1.0)"
    or
    functionWithDomainError = getMathVariants(["atan2", "pow"]) and
    (
      fc.getArgument(0).getValue().toFloat() = 0 and
      fc.getArgument(1).getValue().toFloat() = 0 and
      description = "both arguments are equal to zero"
    )
    or
    functionWithDomainError = getMathVariants("pow") and
    (
      upperBound(fc.getArgument(0)) < 0.0 and
      upperBound(fc.getArgument(1)) < 0.0 and
      description = "both arguments are less than zero"
    )
    or
    functionWithDomainError = getMathVariants("acosh") and
    upperBound(fc.getArgument(0)) < 1.0 and
    description = "argument is less than 1"
    or
    //pole error is the same as domain for logb and tgamma (but not ilogb - no pole error exists)
    functionWithDomainError = getMathVariants(["ilogb", "logb", "tgamma"]) and
    fc.getArgument(0).getValue().toFloat() = 0 and
    description = "argument is equal to zero"
    or
    functionWithDomainError = getMathVariants(["log", "log10", "log2", "sqrt"]) and
    upperBound(fc.getArgument(0)) < 0.0 and
    description = "argument is negative"
    or
    functionWithDomainError = getMathVariants("log1p") and
    upperBound(fc.getArgument(0)) < -1.0 and
    description = "argument is less than 1"
    or
    functionWithDomainError = getMathVariants("fmod") and
    fc.getArgument(1).getValue().toFloat() = 0 and
    description = "y is 0"
  )
}

predicate hasRangeError(FunctionCall fc, string description) {
  exists(Function functionWithRangeError | fc.getTarget() = functionWithRangeError |
    functionWithRangeError.hasGlobalOrStdName(["abs", "labs", "llabs", "imaxabs"]) and
    fc.getArgument(0) = any(MINMacro m).getAnInvocation().getExpr() and
    description = "argument is most negative number"
  )
}

predicate hasPoleError(FunctionCall fc, string description) {
  exists(Function functionWithPoleError | fc.getTarget() = functionWithPoleError |
    functionWithPoleError = getMathVariants("atanh") and
    (
      fc.getArgument(0).getValue().toFloat() = -1.0
      or
      fc.getArgument(0).getValue().toFloat() = 1.0
    ) and
    description = "argument is plus or minus 1"
    or
    functionWithPoleError = getMathVariants("log1p") and
    fc.getArgument(0).getValue().toFloat() = -1 and
    description = "argument is equal to negative one"
    or
    functionWithPoleError = getMathVariants("pow") and
    fc.getArgument(0).getValue().toFloat() = 0.0 and
    fc.getArgument(1).getValue().toFloat() < 0.0 and
    description = "base is zero and exp is negative"
    or
    functionWithPoleError = getMathVariants("lgamma") and
    fc.getArgument(0).getValue().toFloat() = 0 and
    description = "argument is equal to zero"
    or
    functionWithPoleError = getMathVariants(["log", "log10", "log2"]) and
    fc.getArgument(0).getValue().toFloat() = 0.0 and
    description = "argument is equal to zero"
  )
}

predicate unspecifiedValueCases(FunctionCall fc, string description) {
  exists(Function functionWithUnspecifiedResultError |
    fc.getTarget() = functionWithUnspecifiedResultError
  |
    functionWithUnspecifiedResultError = getMathVariants("frexp") and
    (
      fc.getArgument(0) = any(InfinityMacro m).getAnInvocation().getExpr() or
      fc.getArgument(0) = any(NanMacro m).getAnInvocation().getExpr()
    ) and
    description = "Arg is Nan or infinity and exp is unspecified as a result"
  )
}

/**
 * A macro which is representing infinity
 */
class InfinityMacro extends Macro {
  InfinityMacro() { this.getName().toLowerCase().matches("infinity") }
}

/**
 * A macro which is representing nan
 */
class NanMacro extends Macro {
  NanMacro() { this.getName().toLowerCase().matches("nan") }
}

/**
 * A macro which is representing INT_MIN or LONG_MIN or LLONG_MIN
 */
class MINMacro extends Macro {
  MINMacro() { this.getName().toLowerCase().matches(["int_min", "long_min", "llong_min"]) }
}

/*
 * Domain cases not covered by this query:
 *  - pow - x is finite and negative and y is finite and not an integer value.
 *  - tgamma - negative integer can't be covered.
 *  - lrint/llrint/lround/llround - no domain errors checked
 *  - remainder - no domain errors checked.
 *  - remquo - no domain errors checked.
 *
 *  Pole cases not covered by this query:
 *  - lgamma - negative integer can't be covered.
 *
 * Implementations may also define their own domain errors (as per the C99 standard), which are not
 * covered by this query.
 */

query predicate problems(FunctionCall fc, string message) {
  not isExcluded(fc, getQuery()) and
  exists(string description |
    hasDomainError(fc, description) and
    message = "Domain error in call to '" + fc.getTarget().getName() + "': " + description + "."
    or
    hasRangeError(fc, description) and
    message = "Range error in call to '" + fc.getTarget().getName() + "': " + description + "."
    or
    hasPoleError(fc, description) and
    message = "Pole error in call to '" + fc.getTarget().getName() + "': " + description + "."
    or
    unspecifiedValueCases(fc, description) and
    message =
      "Unspecified error in call to '" + fc.getTarget().getName() + "': " + description + "."
  )
}
