/**
 * @id c/misra/arith-conversion-operand-has-different-ess-type-category
 * @name RULE-10-4: Both operands of an operator in which the usual arithmetic conversions are performed shall have the
 * @description Both operands of an operator in which the usual arithmetic conversions are performed
 *              shall have the same essential type category.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-4
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::arithConversionOperandHasDifferentEssTypeCategoryQuery()) and
select
