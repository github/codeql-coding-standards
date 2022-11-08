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

from
where
  not isExcluded(x, Contracts6Package::rightHandOperandOfAShiftOperatorRangeQuery()) and
select
