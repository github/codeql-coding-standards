/**
 * @id c/misra/char-type-exprs-used-in-add-or-sub
 * @name RULE-10-2: Expressions of essentially character type shall not be used inappropriately in addition and
 * @description Expressions of essentially character type shall not be used inappropriately in
 *              addition and subtraction operations.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-2
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::charTypeExprsUsedInAddOrSubQuery()) and
select
