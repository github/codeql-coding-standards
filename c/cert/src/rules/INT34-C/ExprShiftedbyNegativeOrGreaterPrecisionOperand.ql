/**
 * @id c/cert/expr-shiftedby-negative-or-greater-precision-operand
 * @name INT34-C: Bit shift should not be done by a negative operand or an operand of greater-or-equal precision than that of another
 * @description Shifting an expression by an operand that is negative or of precision greater or
 *              equal to that or the another causes representational error.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/int34-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

/* Precision predicate based on a sample implementaion from https://wiki.sei.cmu.edu/confluence/display/c/INT35-C.+Use+correct+integer+precisions */
int getPrecision(BuiltInType type) {
  type.(CharType).isExplicitlyUnsigned() and result = 8
  or
  type.(ShortType).isExplicitlyUnsigned() and result = 16
  or
  type.(IntType).isExplicitlyUnsigned() and result = 32
  or
  type.(LongType).isExplicitlyUnsigned() and result = 32
  or
  type.(LongLongType).isExplicitlyUnsigned() and result = 64
  or
  type instanceof CharType and not type.(CharType).isExplicitlyUnsigned() and result = 7
  or
  type instanceof ShortType and not type.(ShortType).isExplicitlyUnsigned() and result = 15
  or
  type instanceof IntType and not type.(IntType).isExplicitlyUnsigned() and result = 31
  or
  type instanceof LongType and not type.(LongType).isExplicitlyUnsigned() and result = 31
  or
  type instanceof LongLongType and not type.(LongLongType).isExplicitlyUnsigned() and result = 63
}

class MinusNumberLiteral extends UnaryMinusExpr {
  MinusNumberLiteral() { this.getOperand() instanceof Literal }

  override string toString() { result = "-" + this.getOperand().toString() }
}

class ForbiddenShiftExpr extends BinaryBitwiseOperation {
  ForbiddenShiftExpr() {
    (
      /* Precision mismatch between operands */
      getPrecision(this.(LShiftExpr).getLeftOperand().getUnderlyingType()) <=
        getPrecision(this.(LShiftExpr).getRightOperand().getUnderlyingType()) or
      getPrecision(this.(RShiftExpr).getLeftOperand().getUnderlyingType()) <=
        getPrecision(this.(RShiftExpr).getRightOperand().getUnderlyingType()) or
      /* Shifting by a negative number literal */
      this.(LShiftExpr).getRightOperand() instanceof MinusNumberLiteral or
      this.(RShiftExpr).getRightOperand() instanceof MinusNumberLiteral
    )
  }

  predicate hasNegativeOperand() {
    this.(LShiftExpr).getRightOperand() instanceof MinusNumberLiteral or
    this.(RShiftExpr).getRightOperand() instanceof MinusNumberLiteral
  }
}

from ForbiddenShiftExpr badShift, string message
where
  not isExcluded(badShift, TypesPackage::exprShiftedbyNegativeOrGreaterPrecisionOperandQuery()) and
  if badShift.hasNegativeOperand()
  then
    message =
      "The operand " + badShift.getLeftOperand() + " is shifted by a negative expression " +
        badShift.getRightOperand() + "."
  else
    message =
      "The operand " + badShift.getLeftOperand() + " is shifted by an expression " +
        badShift.getRightOperand() + " which is greater than or equal to in precision."
select badShift, message
