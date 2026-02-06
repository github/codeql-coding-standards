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
import codingstandards.cpp.BinaryOperations

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
    Expr left, Expr right, MisraCpp23BuiltInTypes::NumericType leftType, QlBuiltins::BigInt leftVal,
    int rightVal, int maxBit
  |
    left = shift.getLeftOperand() and
    right = shift.getRightOperand() and
    leftType = left.getType() and
    isConstantExpression(left) and
    isConstantExpression(right) and
    MisraCpp23BuiltInTypes::isSignedType(leftType) and
    isValidShiftConstantRange(right, leftType) and
    leftVal = left.getValue().toBigInt() and
    rightVal = right.getValue().toInt() and
    leftVal >= 0.toBigInt() and
    maxBit = leftType.getBuiltInSize() * 8 - 1 and
    // Check that no set bit is shifted into or beyond the sign bit
    leftVal * 2.toBigInt().pow(rightVal) < 2.toBigInt().pow(maxBit)
  )
}

from Expr x, string message
where
  not isExcluded(x, ConversionsPackage::inappropriateBitwiseOrShiftOperandsQuery()) and
  (
    // Binary bitwise operators (excluding shift operations) - both operands must be unsigned
    exists(BinaryBitwiseOpOrAssignOp op, Type operandType |
      not op instanceof BinaryShiftOpOrAssignOp
    |
      x = op.getLeftOperand() and
      operandType = op.getLeftOperand().getExplicitlyConverted().getType() and
      not MisraCpp23BuiltInTypes::isUnsignedType(operandType) and
      message =
        "Bitwise operator '" + op.getOperator() +
          "' requires unsigned numeric operands, but the left operand has type '" + operandType +
          "'."
      or
      x = op.getRightOperand() and
      operandType = op.getRightOperand().getExplicitlyConverted().getType() and
      not MisraCpp23BuiltInTypes::isUnsignedType(operandType) and
      message =
        "Bitwise operator '" + op.getOperator() +
          "' requires unsigned numeric operands, but the right operand has type '" + operandType +
          "'."
    )
    or
    // Bit complement operator - operand must be unsigned
    exists(ComplementExpr comp, Type opType |
      x = comp.getOperand() and
      opType = comp.getOperand().getExplicitlyConverted().getType() and
      not MisraCpp23BuiltInTypes::isUnsignedType(opType) and
      message =
        "Bit complement operator '~' requires unsigned operand, but has type '" + opType + "'."
    )
    or
    // Shift operators - left operand must be unsigned
    exists(BinaryShiftOpOrAssignOp shift, Type leftType |
      x = shift.getLeftOperand() and
      leftType = shift.getLeftOperand().getExplicitlyConverted().getType() and
      not MisraCpp23BuiltInTypes::isUnsignedType(leftType) and
      not isSignedConstantLeftShiftException(shift) and
      message =
        "Shift operator '" + shift.getOperator() +
          "' requires unsigned left operand, but has type '" + leftType + "'."
    )
    or
    // Shift operators - right operand must be unsigned or constant in valid range
    exists(BinaryShiftOpOrAssignOp shift, Expr right, Type rightType, Type leftType |
      right = shift.getRightOperand() and
      x = right and
      rightType = right.getExplicitlyConverted().getType() and
      leftType = shift.getLeftOperand().getExplicitlyConverted().getType()
    |
      if exists(right.getValue().toInt())
      then
        not isValidShiftConstantRange(right, leftType) and
        message =
          "Shift operator '" + shift.getOperator() + "' shifts by " + right.getValue().toInt() +
            " which is not within the valid range 0.." + ((leftType.getSize() * 8) - 1) + "."
      else (
        not MisraCpp23BuiltInTypes::isUnsignedType(rightType) and
        message =
          "Shift operator '" + shift.getOperator() +
            "' requires unsigned right operand, but has type '" + rightType + "'."
      )
    )
  )
select x, message
