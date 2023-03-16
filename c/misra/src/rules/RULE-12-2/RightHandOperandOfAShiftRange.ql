/**
 * @id c/misra/right-hand-operand-of-a-shift-range
 * @name RULE-12-2: The right operand of a shift shall be smaller then the width in bits of the left operand
 * @description The right hand operand of a shift operator shall lie in the range zero to one less
 *              than the width in bits of the essential type of the left hand operand.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-12-2
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

class ShiftExpr extends BinaryBitwiseOperation {
  ShiftExpr() { this instanceof LShiftExpr or this instanceof RShiftExpr }
}

from ShiftExpr e, Expr right, int max_val
where
  not isExcluded(right, Contracts7Package::rightHandOperandOfAShiftRangeQuery()) and
  right = e.getRightOperand().getFullyConverted() and
  max_val = (8 * getEssentialType(e.getLeftOperand()).getSize()) - 1 and
  (
    lowerBound(right) < 0 or
    upperBound(right) > max_val
  )
select right, "The right hand operand of the shift operator shall lie in the range 0 to " + max_val + "."