/**
 * @id c/cert/int-to-float-preserve-precision
 * @name FLP36-C: Preserve precision when converting integral values to floating-point type
 * @description Integer to floating-point conversions may lose precision if the floating-point type
 *              is unable to fully represent the integer value.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/flp36-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

/**
 * Gets the maximum precise integral value for a floating point type, i.e. the maximum value that
 * can be stored without loss of precision, and for which all smaller values can be stored without
 * loss of precision.
 *
 * We make the assumption of a standard IEEE 754 floating point format and use the number of bits
 * in the mantissa to determine the maximum value that can be stored precisely.
 */
float getMaxPreciseValue(FloatingPointType fp) {
  // A 4-byte float has a 23-bit mantissa, but there is an implied leading 1, which makes a total
  // of 24 bits, which can represent (2^24 -1) = 16,777,215 distinct values. However, 2^24 is also
  // fully representable, so the maximum representable value is 2^24.
  fp.getSize() = 4 and result = 2.pow(24)
  or
  // An 8-byte double has a 53-bit mantissa, similar logic to the above.
  fp.getSize() = 8 and result = 2.pow(53)
}

from
  IntegralToFloatingPointConversion c, float maxPreciseValue, string message,
  FloatingPointType targetType
where
  not isExcluded(c, FloatingTypesPackage::intToFloatPreservePrecisionQuery()) and
  targetType = c.getType() and
  // Get the maximum value for which all smaller values can be stored precisely
  maxPreciseValue = getMaxPreciseValue(targetType) and
  (
    // Find the upper bound, and determine if it is greater than the maximum value that can be
    // stored precisely.
    // Note: the range analysis also works on floats (doubles), which means that it also loses
    // precision at the end of the 64 bit mantissa range.
    exists(float upper | upper = upperBound(c.getExpr()) |
      upper > maxPreciseValue and
      message =
        "The upper bound of this value (" + upper + ") cast from " + c.getExpr().getType() + " to " +
          targetType + " is greater than the maximum value (" + maxPreciseValue +
          ") that can be stored precisely."
    )
    or
    // Find the lower bound, and determine if it is less than the negative maximum value that can
    // be stored precisely.
    // Note: the range analysis also works on floats (doubles), which means that it also loses
    // precision at the end of the 64 bit mantissa range.
    exists(float lower | lower = lowerBound(c.getExpr()) |
      lower < -maxPreciseValue and
      message =
        "The lower bound of this value (" + lower + ") cast from " + c.getExpr().getType() + " to " +
          targetType + " is smaller than the minimum value (" + -maxPreciseValue +
          ") that can be stored precisely."
    )
  )
select c, message
