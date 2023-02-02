/**
 * @id c/misra/right-hand-operand-of-a-shift-operator-range
 * @name RULE-12-2: The right hand operand of a shift operator shall lie in the range zero to one less than the width in
 * @description The right hand operand of a shift operator shall lie in the range zero to one less
 *              than the width in bits of the essential type of the left hand operand
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-12-2
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

from BinaryOperation x, int max_size
where
  not isExcluded(x, Contracts6Package::rightHandOperandOfAShiftOperatorRangeQuery()) and
  (x instanceof LShiftExpr or x instanceof RShiftExpr) and
  max_size = (8 * x.getLeftOperand().getExplicitlyConverted().getUnderlyingType().getSize()) - 1 and
  exists(Expr rhs | rhs = x.getRightOperand().getFullyConverted() |
    lowerBound(rhs) < 0 or
    upperBound(rhs) > max_size
  )
select x, "The right hand operand of the shift operator is not in the range 0 to " + max_size + "."
