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

from
where
  not isExcluded(x, TypesPackage::exprShiftedbyNegativeOrGreaterPrecisionOperandQuery()) and
select
