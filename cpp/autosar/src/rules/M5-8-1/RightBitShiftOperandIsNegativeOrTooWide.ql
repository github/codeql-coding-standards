/**
 * @id cpp/autosar/right-bit-shift-operand-is-negative-or-too-wide
 * @name M5-8-1: The right bit-shift operand shall be between zero and one less than the width of the left operand
 * @description It is undefined behaviour if the right hand operand is negative, or greater than or
 *              equal to the width of the left hand operand. If, for example, the left hand operand
 *              of a left-shift or right-shift is a 16-bit integer, then it is important to ensure
 *              that this is shifted only by a number between 0 and 15 inclusive.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-8-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class ShiftOperation extends Operation {
  Expr leftOperand;
  Expr rightOperand;

  ShiftOperation() {
    exists(BinaryBitwiseOperation o | this = o |
      (
        o instanceof LShiftExpr
        or
        o instanceof RShiftExpr
      ) and
      leftOperand = o.getLeftOperand() and
      rightOperand = o.getRightOperand()
    )
    or
    exists(AssignBitwiseOperation o | this = o |
      (
        o instanceof AssignLShiftExpr
        or
        o instanceof AssignRShiftExpr
      ) and
      leftOperand = o.getLValue() and
      rightOperand = o.getRValue()
    )
  }

  Expr getLeftOperand() { result = leftOperand }

  Expr getRightOperand() { result = rightOperand }
}

/*
 * NOTE: This query may not work on some architectures, such as those
 * where a byte is not 8 bits.
 */

from ShiftOperation so, int width, int shift
where
  not isExcluded(so, ExpressionsPackage::rightBitShiftOperandIsNegativeOrTooWideQuery()) and
  width = so.getLeftOperand().getFullyConverted().getType().getSize() * 8 and
  shift = so.getRightOperand().getValue().toInt() and
  (shift < 0 or shift >= width)
select so.getRightOperand(),
  "Bit-shift amount, " + shift + ", is either negative or larger than the width, " + width + "."
