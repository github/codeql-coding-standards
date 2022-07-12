/**
 * @id cpp/autosar/unchecked-range-domain-pole-errors
 * @name A0-4-4: Range, domain and pole errors shall be checked when using math functions
 * @description Range, domain or pole errors in math functions may return unexpected values, trigger
 *              floating-point exceptions or set unexpected error modes.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a0-4-4
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

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

from FunctionCall fc, string description
where
  not isExcluded(fc, TypeRangesPackage::uncheckedRangeDomainPoleErrorsQuery()) and
  hasDomainError(fc, description)
select fc, "Domain error in call to " + fc.getTarget().getName() + ": " + description + "."
