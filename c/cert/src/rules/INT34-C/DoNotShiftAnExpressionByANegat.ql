/**
 * @id c/cert/do-not-shift-an-expression-by-a-negat
 * @name INT34-C: Do not shift an expression by a negative number of bits or by greater than or equal to the number of
 * @description Do not shift an expression by a negative number of bits or by greater than or equal
 *              to the number of bits that exist in the operand..
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
  not isExcluded(x, TypesPackage::doNotShiftAnExpressionByANegatQuery()) and
select
