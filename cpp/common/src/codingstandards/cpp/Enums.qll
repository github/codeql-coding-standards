/**
 * A module providing predicates for computing properties of enumerations.
 *
 * This module provides predicates for the following:
 *
 *  - Identifying the fixed underlying type of an enumeration, if any.
 *  - Determining the "value range" of an enumeration, considering the
 *    kind of enumeration (scoped, unscoped and fixed or not fixed).
 *
 * These concepts are described in `[dcl.enum]`.
 */

import cpp
private import semmle.code.cpp.rangeanalysis.RangeAnalysisUtils

module Enums {
  /**
   * Gets the fixed underlying type of `e`, if any.
   *
   * An enum is said to have a fixed underlying type if an enum base is specified, or if it is a
   * scoped enumeration without a specified base (in which case the enumeration has an underlying
   * type of int). For example:
   * ```
   * enum A : int { ... }; // Fixed underlying type
   * enum class B : int { ... }; // Fixed underlying type
   * enum class C { ... }; // Fixed underlying type
   * enum D { ... }; // No fixed underlying type
   * ```
   */
  Type getFixedUnderlyingType(Enum e) {
    if e.hasExplicitUnderlyingType()
    then result = e.getExplicitUnderlyingType().getUnspecifiedType()
    else (
      // Scoped enums default to `int`
      e instanceof ScopedEnum and
      result instanceof IntType and
      result.hasName("int")
    )
  }

  /**
   * Holds if the enum `e` has a fixed underlying type.
   *
   * An enum is said to have a fixed underlying type if an enum base is specified, or if it is a
   * scoped enumeration without a specified base (in which case the enumeration has an underlying
   * type of int). For example:
   * ```
   * enum A : int { ... }; // Fixed underlying type
   * enum class B : int { ... }; // Fixed underlying type
   * enum class C { ... }; // Fixed underlying type
   * enum D { ... }; // No fixed underlying type
   * ```
   */
  predicate hasFixedUnderlyingType(Enum e) { exists(getFixedUnderlyingType(e)) }

  /** Gets the float value associated with a constant. */
  float getEnumConstantValue(EnumConstant ec) { result = ec.getValue().toFloat() }

  /**
   * Gets the smallest enum constant.
   */
  float getMinEnumValue(Enum e) {
    result = min(float f | f = getEnumConstantValue(e.getAnEnumConstant()) | f)
    or
    // If there are no constants, the standard says "the values of the enumeration are as if
    // the enumeration had a single enumerator with value 0".
    not exists(e.getAnEnumConstant()) and
    result = 0
  }

  /**
   * Gets the largest enum constant.
   */
  float getMaxEnumValue(Enum e) {
    result = max(float f | f = getEnumConstantValue(e.getAnEnumConstant()) | f)
    or
    // If there are no constants, the standard says "the values of the enumeration are as if
    // the enumeration had a single enumerator with value 0".
    not exists(e.getAnEnumConstant()) and
    result = 0
  }

  /**
   * Gets the value range of a non-fixed enum as specified in `[dcl.enum]/8`.
   *
   * For enums with no fixed underlying type, the value range is specified by a calculation in
   * `[dcl.enum]/8` that essentially identifies the smallest number of binary digits required to
   * hold all the values of the enum. The range of values that can be described in those digits
   * is then considered the value range of the enum. Note: this may include values that are not
   * specified in an enum constant.
   *
   * This predicate assumes the use of two's complement representation.
   */
  predicate getNonFixedRange(Enum e, float bMin, float bMax) {
    exists(int k |
      not hasFixedUnderlyingType(e) and
      // Assuming two's complement representation
      k = 1 and
      // Find the largest and smallest enumerators
      exists(float eMin, float eMax |
        eMin = getMinEnumValue(e) and
        eMax = getMaxEnumValue(e)
      |
        // Find bMax
        exists(float maxAbsVal |
          // Find the largest absolute value that needs to be stored
          maxAbsVal = (eMin.abs() - k).maximum(eMax.abs()) and
          // Find m - the number of binary digits required to store the largest absolute value
          exists(int m |
            // Find non-negative `m` such that (2**m - 1) is greater than or equal to `maxAbsVal`
            m = (maxAbsVal + 1).log2().ceil()
            or
            // If `maxAbsVal` is negative, then `m` is `0`.
            maxAbsVal < 0 and m = 0
          |
            bMax = 2.pow(m) - 1
          )
        ) and
        // If eMin is negative, then we need to use a sign bit, and the smallest value in our range
        // is therefore related to the largest value required. Otherwise, 0 is the smallest value.
        (if eMin >= 0 then bMin = 0 else bMin = -(bMax + k))
      )
    )
  }

  /**
   * Gets a lower bound on the value range for the `Enum` `e`.
   */
  float getValueRangeLowerBound(Enum e) {
    if hasFixedUnderlyingType(e)
    then result = typeLowerBound(getFixedUnderlyingType(e))
    else getNonFixedRange(e, result, _)
  }

  /**
   * Gets an upper bound on the value range for the `Enum` `e`.
   */
  float getValueRangeUpperBound(Enum e) {
    if hasFixedUnderlyingType(e)
    then result = typeUpperBound(getFixedUnderlyingType(e))
    else getNonFixedRange(e, _, result)
  }

  /**
   * Holds if the value range of the enum suggests that every value in the range
   */
  predicate isContiguousEnum(Enum e) {
    exists(int enumCount |
      enumCount = count(EnumConstant ec | e.getAnEnumConstant() = ec) and
      not exists(EnumConstant ec1, EnumConstant ec2 |
        ec1 = e.getAnEnumConstant() and
        ec2 = e.getAnEnumConstant() and
        getEnumConstantValue(ec1) = getEnumConstantValue(ec2) and
        not ec1 = ec2
      ) and
      enumCount = (getMaxEnumValue(e) - getMinEnumValue(e)).floor() + 1
    )
  }
}
