/**
 * @id cpp/misra/inappropriate-bitwise-or-shift-operands
 * @name RULE-7-0-4: The operands of bitwise operators and shift operators shall be appropriate
 * @description Bitwise and shift operators should only be applied to operands of appropriate types
 *              and values to avoid implementation-defined or undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-0-4
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.misra.BuiltInTypeRules

predicate isConstantExpression(Expr e) {
  e instanceof Literal or
  e.isConstant()
}

predicate isValidShiftConstantRange(Expr right, Type leftType) {
  exists(int value |
    value = right.getValue().toInt() and
    value >= 0 and
    value < leftType.getSize() * 8
  )
}

predicate isSignedConstantLeftShiftException(LShiftExpr shift) {
  exists(
    Expr left, Expr right, NumericType leftType, QlBuiltins::BigInt leftVal, int rightVal,
    int maxBit
  |
    left = shift.getLeftOperand() and
    right = shift.getRightOperand() and
    leftType = left.getType() and
    isConstantExpression(left) and
    isConstantExpression(right) and
    isSignedType(leftType) and
    isValidShiftConstantRange(right, leftType) and
    leftVal = left.getValue().toBigInt() and
    rightVal = right.getValue().toInt() and
    leftVal >= 0.toBigInt() and
    maxBit = leftType.getSize() * 8 - 1 and
    // Check that no set bit is shifted into or beyond the sign bit
    leftVal * 2.toBigInt().pow(rightVal) < 2.toBigInt().pow(maxBit)
  )
}

class BinaryShiftOperation extends BinaryOperation {
  BinaryShiftOperation() {
    this instanceof LShiftExpr or
    this instanceof RShiftExpr
  }
}

class AssignShiftOperation extends AssignOperation {
  AssignShiftOperation() {
    this instanceof AssignLShiftExpr or
    this instanceof AssignRShiftExpr
  }
}

from Expr x, string message
where
  not isExcluded(x, ConversionsPackage::inappropriateBitwiseOrShiftOperandsQuery()) and
  (
    // Binary bitwise operators (excluding shift operations) - both operands must be unsigned
    exists(BinaryBitwiseOperation op |
      not op instanceof BinaryShiftOperation and
      op = x and
      not (
        isUnsignedType(op.getLeftOperand().getExplicitlyConverted().getType()) and
        isUnsignedType(op.getRightOperand().getExplicitlyConverted().getType())
      ) and
      message =
        "Binary bitwise operator '" + op.getOperator() + "' requires both operands to be unsigned."
    )
    or
    // Compound assignment bitwise operators - both operands must be unsigned
    exists(AssignBitwiseOperation op |
      not op instanceof AssignShiftOperation and
      op = x and
      not (
        isUnsignedType(op.getLValue().getExplicitlyConverted().getType()) and
        isUnsignedType(op.getRValue().getExplicitlyConverted().getType())
      ) and
      message =
        "Compound assignment bitwise operator '" + op.getOperator() +
          "' requires both operands to be unsigned."
    )
    or
    // Bit complement operator - operand must be unsigned
    exists(ComplementExpr comp |
      comp = x and
      not isUnsignedType(comp.getOperand().getExplicitlyConverted().getType()) and
      message = "Bit complement operator '~' requires unsigned operand."
    )
    or
    // Shift operators - left operand must be unsigned
    exists(BinaryShiftOperation shift |
      shift = x and
      not isUnsignedType(shift.getLeftOperand().getExplicitlyConverted().getType()) and
      not isSignedConstantLeftShiftException(shift) and
      message = "Shift operator '" + shift.getOperator() + "' requires unsigned left operand."
    )
    or
    // Compound assignment shift operators - left operand must be unsigned
    exists(AssignShiftOperation shift |
      shift = x and
      not isUnsignedType(shift.getLValue().getExplicitlyConverted().getType()) and
      message = "Shift operator '" + shift.getOperator() + "' requires unsigned left operand."
    )
    or
    // Shift operators - right operand must be unsigned or constant in valid range
    exists(BinaryShiftOperation shift, Expr right |
      shift = x and
      right = shift.getRightOperand() and
      not isUnsignedType(right.getExplicitlyConverted().getType()) and
      not isValidShiftConstantRange(right, shift.getLeftOperand().getExplicitlyConverted().getType()) and
      message =
        "Shift operator '" + shift.getOperator() +
          "' requires unsigned right operand or constant in valid range."
    )
    or
    // Compound assignment shift operators - right operand must be unsigned or constant in valid range
    exists(AssignShiftOperation shift, Expr right |
      shift = x and
      right = shift.getRValue() and
      not isUnsignedType(right.getExplicitlyConverted().getType()) and
      not isValidShiftConstantRange(right, shift.getLValue().getExplicitlyConverted().getType()) and
      message =
        "Shift operator '" + shift.getOperator() +
          "' requires unsigned right operand or constant in valid range."
    )
  )
select x, message
