import cpp

private signature class BinaryOp extends BinaryOperation;

private signature class AssignBinaryOp extends AssignOperation;

/**
 * A module for unifying the `BinaryOperation` and `AssignOperation` hierarchies.
 */
private module BinaryOpUnifier<BinaryOp BinaryOpType, AssignBinaryOp AssignBinaryOpType> {
  final class FinalExpr = Expr;

  class BinaryExpr extends FinalExpr {
    BinaryExpr() {
      this instanceof BinaryOpType or
      this instanceof AssignBinaryOpType
    }

    Expr getLeftOperand() {
      result = this.(BinaryOpType).getLeftOperand()
      or
      result = this.(AssignBinaryOpType).getLValue()
    }

    Expr getRightOperand() {
      result = this.(BinaryOpType).getRightOperand()
      or
      result = this.(AssignBinaryOpType).getRValue()
    }

    string getOperator() {
      result = this.(BinaryOpType).getOperator()
      or
      result = this.(AssignBinaryOpType).getOperator()
    }
  }
}

/**
 * A binary shift operation (`<<` or `>>`).
 */
class BinaryShiftOperation extends BinaryOperation {
  BinaryShiftOperation() {
    this instanceof LShiftExpr or
    this instanceof RShiftExpr
  }
}

/**
 * A binary shift assignment operation (`<<=` or `>>=`).
 */
class AssignShiftOperation extends AssignOperation {
  AssignShiftOperation() {
    this instanceof AssignLShiftExpr or
    this instanceof AssignRShiftExpr
  }
}

/**
 * A binary bitwise operation or binary bitwise assignment operation, including shift operations.
 */
class BinaryBitwiseOpOrAssignOp =
  BinaryOpUnifier<BinaryBitwiseOperation, AssignBitwiseOperation>::BinaryExpr;

/**
 * A binary shift operation (`<<` or `>>`) or shift assignment operation (`<<=` or `>>=`).
 */
class BinaryShiftOpOrAssignOp =
  BinaryOpUnifier<BinaryShiftOperation, AssignShiftOperation>::BinaryExpr;

/**
 * A binary arithmetic operation or binary arithmetic assignment operation.
 */
class BinaryArithmeticOpOrAssignOp =
  BinaryOpUnifier<BinaryArithmeticOperation, AssignArithmeticOperation>::BinaryExpr;
