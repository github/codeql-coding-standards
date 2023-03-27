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
  )
}

/*
 * Domain cases not covered by this query:
 *  - pow - x is finite and negative and y is finite and not an integer value.
 *  - tgamma - negative integer can't be covered.
 *  - lrint/llrint/lround/llround - no domain errors checked
 *  - fmod - no domain errors checked.
 *  - remainder - no domain errors checked.
 *  - remquo - no domain errors checked.
 *
 * Implementations may also define their own domain errors (as per the C99 standard), which are not
 * covered by this query.
 */

query predicate problems(FunctionCall fc, string message) {
  not isExcluded(fc, getQuery()) and
  exists(string description |
    hasDomainError(fc, description) and
    message = "Domain error in call to " + fc.getTarget().getName() + ": " + description + "."
  )
}
