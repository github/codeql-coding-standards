/**
 * @id c/misra/low-precision-periodic-trigonometric-function-call
 * @name DIR-4-11: The validity of values passed to trigonometric functions shall be checked
 * @description Trigonometric periodic functions have significantly less precision when called with
 *              large floating-point values.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/dir-4-11
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

float getMaxAllowedAbsoluteValue(FloatingPointType t, string description) {
  if t.getSize() <= 4
  then (
    // Per MISRA, assume k=1 for float types.
    result = 3.15 and description = "pi"
  ) else (
    // Allow k=10 for doubles, as the standard allows for a larger range depending on the
    // implementation, application, and precision goals.
    result = 10 * 3.15 and description = "10 * pi"
  )
}

from FunctionCall fc, Expr argument, float maxValue, float maxAllowedValue, string maxAllowedStr
where
  not isExcluded(fc, ContractsPackage::lowPrecisionPeriodicTrigonometricFunctionCallQuery()) and
  fc.getTarget().getName() = ["sin", "cos", "tan"] and
  argument = fc.getArgument(0) and
  maxValue = rank[1](float bound | bound = [lowerBound(argument), upperBound(argument)].abs()) and
  maxAllowedValue = getMaxAllowedAbsoluteValue(argument.getType(), maxAllowedStr) and
  maxValue > maxAllowedValue
select fc,
  "Call to periodic trigonometric function " + fc.getTarget().getName() +
    " with maximum argument absolute value of " + maxValue.toString() +
    ", which exceeds the recommended " + "maximum of " + maxAllowedStr + "."
