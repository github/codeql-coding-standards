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
    rightOperandType = binOp.getRightOperand().getExplicitlyConverted().getUnderlyingType() and
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

predicate assignmentSourceIsUnscopedUnfixedEnum(AssignExpr assign) { none() }

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
