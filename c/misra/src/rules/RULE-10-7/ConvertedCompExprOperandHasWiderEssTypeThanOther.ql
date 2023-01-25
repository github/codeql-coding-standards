/**
 * @id c/misra/converted-comp-expr-operand-has-wider-ess-type-than-other
 * @name RULE-10-7: If a composite expression is used as one operand of an operator in which the usual arithmetic
 * @description If a composite expression is used as one operand of an operator in which the usual
 *              arithmetic conversions are performed then the other operand shall not have wider
 *              essential type.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-7
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::convertedCompExprOperandHasWiderEssTypeThanOtherQuery()) and
select
