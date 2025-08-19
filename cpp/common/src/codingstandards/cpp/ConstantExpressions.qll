import cpp

final private class FinalExpr = Expr;

/**
 * An integer constant expression as defined by the C++17 standard.
 */
class IntegerConstantExpr extends FinalExpr {
  IntegerConstantExpr() {
    // An integer constant expression is a constant expression that has an
    // integral type.
    this.isConstant() and
    exists(Type unspecifiedType | unspecifiedType = this.getUnspecifiedType() |
      unspecifiedType instanceof IntegralType
      or
      // Unscoped enum type
      unspecifiedType instanceof Enum and
      not unspecifiedType instanceof ScopedEnum
    )
  }

  /**
   * Gets the value of this integer constant expression.
   *
   * This is only defined for expressions that are constant expressions, and
   * that have a value that can be represented as a `BigInt`.
   */
  QlBuiltins::BigInt getConstantValue() {
    if exists(getPreConversionConstantValue())
    then result = getPreConversionConstantValue()
    else result = this.getValue().toBigInt()
  }

  /**
   * Gets the pre-conversion constant value of this integer constant expression, if it is different
   * from `getValue()`.
   *
   * This is required because `Expr.getValue()` returns the _converted constant expression value_
   * for non-literal constant expressions, which is the expression value after conversions have been
   * applied, but for validating conversions we need the _pre-conversion constant expression value_.
   */
  private QlBuiltins::BigInt getPreConversionConstantValue() {
    // Access of a variable that has a constant initializer
    result =
      this.(VariableAccess)
          .getTarget()
          .getInitializer()
          .getExpr()
          .getFullyConverted()
          .getValue()
          .toBigInt()
    or
    result = this.(EnumConstantAccess).getTarget().getValue().toBigInt()
    or
    result = -this.(UnaryMinusExpr).getOperand().getFullyConverted().getValue().toBigInt()
    or
    result = this.(UnaryPlusExpr).getOperand().getFullyConverted().getValue().toBigInt()
    or
    result = this.(ComplementExpr).getOperand().getFullyConverted().getValue().toBigInt().bitNot()
    or
    exists(BinaryOperation op, QlBuiltins::BigInt left, QlBuiltins::BigInt right |
      op = this and
      left = op.getLeftOperand().getFullyConverted().getValue().toBigInt() and
      right = op.getRightOperand().getFullyConverted().getValue().toBigInt()
    |
      op instanceof AddExpr and
      result = left + right
      or
      op instanceof SubExpr and
      result = left - right
      or
      op instanceof MulExpr and
      result = left * right
      or
      op instanceof DivExpr and
      result = left / right
      or
      op instanceof RemExpr and
      result = left % right
      or
      op instanceof BitwiseAndExpr and
      result = left.bitAnd(right)
      or
      op instanceof BitwiseOrExpr and
      result = left.bitOr(right)
      or
      op instanceof BitwiseXorExpr and
      result = left.bitXor(right)
      or
      op instanceof RShiftExpr and
      result = left.bitShiftRightSigned(right.toInt())
      or
      op instanceof LShiftExpr and
      result = left.bitShiftLeft(right.toInt())
    )
  }
}
