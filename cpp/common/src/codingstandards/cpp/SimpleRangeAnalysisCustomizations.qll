/**
 * A module for extensions to the `SimpleRangeAnalysis` library.
 *
 * This module provides extensions for:
 *  - Bitwise and operations where one or more operands are constants.
 *  - Bitwise or operations where one or more operands are constants.
 *  - Casts from enumerations to integers.
 */

import cpp
import codingstandards.cpp.Enums
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
import semmle.code.cpp.rangeanalysis.RangeAnalysisUtils
import experimental.semmle.code.cpp.rangeanalysis.extensions.ConstantBitwiseAndExprRange
private import experimental.semmle.code.cpp.models.interfaces.SimpleRangeAnalysisExpr

/**
 * A range analysis extension that support bitwise `|` and `|=` where at least one operand is a
 * non-negative constant.
 */
private class ConstantBitwiseOrExprRange extends SimpleRangeAnalysisExpr {
  ConstantBitwiseOrExprRange() {
    exists(Expr l, Expr r |
      l = this.(BitwiseOrExpr).getLeftOperand() and
      r = this.(BitwiseOrExpr).getRightOperand()
      or
      l = this.(AssignOrExpr).getLValue() and
      r = this.(AssignOrExpr).getRValue()
    |
      // No operands can be negative constants
      not (evaluateConstantExpr(l) < 0 or evaluateConstantExpr(r) < 0) and
      // At least one operand must be a non-negative constant
      (evaluateConstantExpr(l) >= 0 or evaluateConstantExpr(r) >= 0)
    )
  }

  Expr getLeftOperand() {
    result = this.(BitwiseOrExpr).getLeftOperand() or
    result = this.(AssignOrExpr).getLValue()
  }

  Expr getRightOperand() {
    result = this.(BitwiseOrExpr).getRightOperand() or
    result = this.(AssignOrExpr).getRValue()
  }

  override float getLowerBounds() {
    // If an operand can have negative values, the lower bound is unconstrained.
    // Otherwise, the lower bound is zero.
    exists(float lLower, float rLower |
      lLower = getFullyConvertedLowerBounds(getLeftOperand()) and
      rLower = getFullyConvertedLowerBounds(getRightOperand()) and
      // If both values are two's complement, and at least one is a non-negative constant
      // then a bitwise `|` operation is guaranteed to produce a number no smaller than the
      // smallest of the original numbers
      result = lLower.minimum(rLower)
    )
  }

  override float getUpperBounds() {
    // If an operand can have negative values, the upper bound is unconstrained.
    // Otherwise, the upper bound is the minimum of the upper bounds of the operands
    exists(float lUpper, float rUpper |
      lUpper = getFullyConvertedUpperBounds(getLeftOperand()) and
      rUpper = getFullyConvertedUpperBounds(getRightOperand()) and
      (
        // Both arguments have a positive maximum value
        lUpper >= 0 and
        rUpper >= 0 and
        // For each operand find the smallest (2^y - 1) value which is greater than or equal to the
        // operands
        // The maximum of these values is the maximum of the upper bounds of the operands
        result =
          (2.pow((lUpper + 1).log2().ceil()) - 1).maximum(2.pow((rUpper + 1).log2().ceil()) - 1)
        or
        // Otherwise revert to the largest expression of this type
        (lUpper < 0 or rUpper < 0) and
        result = exprMaxVal(this)
      )
    )
  }

  override predicate dependsOnChild(Expr child) {
    child = getLeftOperand() or child = getRightOperand()
  }
}

/**
 * A class for modeling conversions from enums to integer types.
 *
 * Note: this does not cover enum to bool or float conversions.
 */
private class CastEnumToIntegerSimpleRange extends SimpleRangeAnalysisExpr, Cast {
  CastEnumToIntegerSimpleRange() {
    /*
     * This is a conversion from an enum to an integer.
     *
     * How this is interpreted depends on whether the enum is scoped or unscoped:
     *  - _Unscoped_ - according to `[dcl.enum]/10` "the value of an enumerator or an object of an
     *                 unscoped enumeration type is converted to an integer by integral promotion"
     *  - _Scoped_ - according to `[expr.static.cast]/9` "For the remaining integral types, the
     *               value is unchanged if the original value can be represented by the specified
     *               type. Otherwise, the resulting value is unspecified."
     *
     * Note: the conversion does not depend on whether the underlying type is fixed or not.
     */

    getExpr().getType().getUnspecifiedType() instanceof Enum and
    getType().getUnspecifiedType() instanceof IntegralType
  }

  /** Gets the enum type being converted. */
  Enum getEnumType() { result = getExpr().getType().getUnspecifiedType() }

  /**
   * Holds if the enum type being cast has a value range that is entirely representable in the
   * integer type.
   */
  predicate isEnumValueRangeWithinIntegerRange() {
    Enums::getValueRangeLowerBound(getEnumType()) >= typeLowerBound(getType().getUnspecifiedType()) and
    Enums::getValueRangeUpperBound(getEnumType()) <= typeUpperBound(getType().getUnspecifiedType())
  }

  override float getLowerBounds() {
    // If it's within the range, then we simply propagate the bounds
    isEnumValueRangeWithinIntegerRange() and
    (
      if exists(getValue(getExpr()))
      then result = getValue(getExpr()).toFloat() // TODO check if value is out of range, then unspecified
      else result = Enums::getValueRangeLowerBound(getEnumType())
    )
    or
    // Enum values do not fit into the range
    not isEnumValueRangeWithinIntegerRange() and
    result = exprMinVal(this)
  }

  override float getUpperBounds() {
    // If it's within the range, then we simply propagate the bounds
    isEnumValueRangeWithinIntegerRange() and
    (
      if exists(getValue(getExpr()))
      then result = getValue(getExpr()).toFloat()
      else result = Enums::getValueRangeUpperBound(getEnumType())
    )
    or
    not isEnumValueRangeWithinIntegerRange() and
    result = exprMaxVal(this)
  }

  override predicate dependsOnChild(Expr child) { child = getExpr() }
}

/**
 * A range analysis extension that supports `%=`.
 */
private class RemAssignSimpleRange extends SimpleRangeAnalysisExpr, AssignRemExpr {
  override float getLowerBounds() {
    exists(float maxDivisorNegated, float dividendLowerBounds |
      // Find the max divisor, negated e.g. `%= 32` would be  `-31`
      maxDivisorNegated = (getFullyConvertedUpperBounds(getRValue()).abs() - 1) * -1 and
      // Find the lower bounds of the dividend
      dividendLowerBounds = getFullyConvertedLowerBounds(getLValue()) and
      // The lower bound is calculated in two steps:
      // 1. Determine the maximum of the dividend lower bound and maxDivisorNegated.
      //    When the dividend is negative this will result in a negative result
      // 2. Find the minimum with 0. If the divided is always >0 this will produce 0
      //    otherwise it will produce the lowest negative number that can be held
      //    after the modulo.
      result = 0.minimum(dividendLowerBounds.maximum(maxDivisorNegated))
    )
  }

  override float getUpperBounds() {
    exists(float maxDivisor, float maxDividend |
      // The maximum divisor value is the absolute value of the divisor minus 1
      maxDivisor = getFullyConvertedUpperBounds(getRValue()).abs() - 1 and
      // value if > 0 otherwise 0
      maxDividend = getFullyConvertedUpperBounds(getLValue()).maximum(0) and
      // In the case the numerator is definitely less than zero, the result could be negative
      result = maxDividend.minimum(maxDivisor)
    )
  }

  override predicate dependsOnChild(Expr expr) { expr = getAChild() }
}

/**
 * <stdio.h> functions that read a character from the STDIN,
 * or return EOF if it fails to do so.
 * Their return type is `int` by their signatures, but
 * they actually return either an unsigned char or an EOF.
 */
private class CtypeGetcharFunctionsRange extends SimpleRangeAnalysisExpr, FunctionCall {
  CtypeGetcharFunctionsRange() {
    this.getTarget().getFile().(HeaderFile).getBaseName() = "stdio.h" and
    this.getTarget().getName().regexpMatch("(fgetc|getc|getchar|)")
  }

  /* It can return an EOF, which is -1 on most implementations. */
  override float getLowerBounds() { result = -1 }

  /* Otherwise, it can return any unsigned char. */
  override float getUpperBounds() { result = 255 }

  /* No, its call does not depend on any of its child. */
  override predicate dependsOnChild(Expr expr) { none() }
}

/**
 * Gets the value of the expression `e`, if it is a constant.
 *
 * This predicate also handles the case of constant variables initialized in different
 * compilation units, which doesn't necessarily have a getValue() result from the extractor.
 *
 * NOTE: Copied from `SimpleRangeAnalysis`, as it is private to that library.
 */
private string getValue(Expr e) {
  if exists(e.getValue())
  then result = e.getValue()
  else
    /*
     * It should be safe to propagate the initialization value to a variable if:
     * The type of v is const, and
     * The type of v is not volatile, and
     * Either:
     *   v is a local/global variable, or
     *   v is a static member variable
     */

    exists(VariableAccess access, StaticStorageDurationVariable v |
      not v.getUnderlyingType().isVolatile() and
      v.getUnderlyingType().isConst() and
      e = access and
      v = access.getTarget() and
      result = getValue(v.getAnAssignedValue())
    )
}
