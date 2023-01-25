/**
 * @id c/misra/comp-expr-val-cast-to-incompat-ess-type
 * @name RULE-10-8: The value of a composite expression shall not be cast to a different essential type category or a
 * @description The value of a composite expression shall not be cast to a different essential type
 *              category or a wider essential type.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-8
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::compExprValCastToIncompatEssTypeQuery()) and
select
