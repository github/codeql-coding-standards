/**
 * @id cpp/misra/unscoped-enum-without-fixed-underlying-type-used
 * @name RULE-10-2-3: The numeric value of an unscoped enumeration with no fixed underlying type shall not be used
 * @description Treating unscoped enumeration without a fixed underlying type as an integral type is
 *              not portable and might cause unintended behaviors.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-2-3
 *       scope/single-translation-unit
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

private predicate isUnscopedEnum(Enum enum) { not enum instanceof ScopedEnum }

private predicate withoutFixedUnderlyingType(Enum enum) { not enum.hasExplicitUnderlyingType() }

private predicate isUnscopedEnumWithoutFixedUnderlyingType(Enum enum) {
  isUnscopedEnum(enum) and withoutFixedUnderlyingType(enum)
}

class ArithmeticBitwiseLogicalBinaryOperation extends BinaryOperation {
  ArithmeticBitwiseLogicalBinaryOperation() {
    this instanceof BinaryArithmeticOperation or
    this instanceof BinaryBitwiseOperation or
    this instanceof BinaryLogicalOperation
  }
}

/**
 * ``` C++
 * static_cast<int>(u) == static_cast<int>(s); // COMPLIANT: comparing ints
 * ```
 * ^^^ To solve this, we use `getExplicitlyConverted`:
 * `binOp.getLeftOperand().getExplicitlyConverted()` gives `int`.
 */
predicate arithmeticBitwiseLogicalOperationUsesUnscopedUnfixedEnum(
  ArithmeticBitwiseLogicalBinaryOperation binOp
) {
  /*
   * We want to strip explicit casts and not implicit ones. Without the
   * stripping of explicit casts, our query would raise a false alarm on
   * cases such as below.
   *
   * ``` C++
   * static_cast<int>(u) + 1   // COMPLIANT
   * ```
   */

  isUnscopedEnumWithoutFixedUnderlyingType(binOp
        .getLeftOperand()
        .getExplicitlyConverted()
        .getUnderlyingType()) or
  isUnscopedEnumWithoutFixedUnderlyingType(binOp
        .getRightOperand()
        .getExplicitlyConverted()
        .getUnderlyingType())
}

class RelationalEqualityBinaryOperation extends BinaryOperation {
  RelationalEqualityBinaryOperation() {
    this instanceof RelationalOperation or
    this instanceof EqualityOperation
  }
}

predicate relationalEqualityOperationUsesUnscopedUnfixedEnum(RelationalEqualityBinaryOperation binOp) {
  exists(Type leftOperandType, Type rightOperandType |
    /*
     * We want to strip explicit casts and not implicit ones. Without the
     * stripping of explicit casts, our query would raise a false alarm on
     * cases such as below.
     *
     * ``` C++
     * static_cast<int>(u) == 1   // COMPLIANT
     * ```
     */

    leftOperandType = binOp.getLeftOperand().getExplicitlyConverted().getUnderlyingType() and
    rightOperandType = binOp.getRightOperand().getExplicitlyConverted().getUnderlyingType()
  |
    (
      isUnscopedEnumWithoutFixedUnderlyingType(leftOperandType)
      or
      isUnscopedEnumWithoutFixedUnderlyingType(rightOperandType)
    ) and
    leftOperandType != rightOperandType
  )
}

class ArithmeticBitwiseCompoundAssignment extends AssignOperation {
  ArithmeticBitwiseCompoundAssignment() {
    this instanceof AssignArithmeticOperation or
    this instanceof AssignBitwiseOperation
  }
}

predicate compoundAssignmentUsesUnscopedUnfixedEnum(
  ArithmeticBitwiseCompoundAssignment compoundAssignment
) {
  isUnscopedEnumWithoutFixedUnderlyingType(compoundAssignment.getAnOperand().getUnderlyingType())
}

predicate assignmentSourceIsUnscopedUnfixedEnum(AssignExpr assign) {
  isUnscopedEnumWithoutFixedUnderlyingType(assign.getRValue().getUnderlyingType())
}

/**
 * Gets the minimum number of bits required to hold all values of enum `e`.
 */
int enumMinBits(Enum e, boolean signed) {
  exists(QlBuiltins::BigInt minVal, QlBuiltins::BigInt maxVal |
    minVal = min(EnumConstant c | c.getDeclaringEnum() = e | c.getValue().toBigInt()) and
    maxVal = max(EnumConstant c | c.getDeclaringEnum() = e | c.getValue().toBigInt())
  |
    // 8 bits: signed [-128, 127] or unsigned [0, 255]
    if minVal >= "-128".toBigInt() and maxVal <= "127".toBigInt()
    then result = 8 and signed = true
    else
      if minVal >= "0".toBigInt() and maxVal <= "255".toBigInt()
      then (
        result = 8 and signed = false
      ) else
        // 16 bits: signed [-32768, 32767] or unsigned [0, 65535]
        if minVal >= "-32768".toBigInt() and maxVal <= "32767".toBigInt()
        then (
          result = 16 and signed = true
        ) else
          if minVal >= "0".toBigInt() and maxVal <= "65535".toBigInt()
          then (
            result = 16 and signed = false
          ) else
            // 32 bits: signed [-2147483648, 2147483647] or unsigned [0, 4294967295]
            if minVal >= "-2147483648".toBigInt() and maxVal <= "2147483647".toBigInt()
            then (
              result = 32 and signed = true
            ) else
              if minVal >= "0".toBigInt() and maxVal <= "4294967295".toBigInt()
              then (
                result = 32 and signed = false
              ) else (
                // 64 bits: everything else
                result = 64 and signed = true
              )
  )
}

/**
 * Holds if the enum `e` can fit in an integral type `type`.
 */
predicate enumFitsInType(Enum e, IntegralType type) {
  exists(int minBits, boolean signed | minBits = enumMinBits(e, signed) |
    type.getSize() * 8 = minBits and
    (
      signed = true and type.isSigned()
      or
      signed = false and type.isUnsigned()
    )
  )
}

predicate staticCastSourceIsUnscopedUnfixedEnumVariant(StaticCast cast) { none() }

predicate switchCaseIsAnUnfixedEnumVariant(SwitchCase switchCase) { none() }

from Element x
where
  not isExcluded(x, Banned3Package::unscopedEnumWithoutFixedUnderlyingTypeUsedQuery()) and
  (
    arithmeticBitwiseLogicalOperationUsesUnscopedUnfixedEnum(x) or
    relationalEqualityOperationUsesUnscopedUnfixedEnum(x) or
    compoundAssignmentUsesUnscopedUnfixedEnum(x) or
    assignmentSourceIsUnscopedUnfixedEnum(x) or
    staticCastSourceIsUnscopedUnfixedEnumVariant(x) or
    switchCaseIsAnUnfixedEnumVariant(x)
  )
select x, "TODO"
