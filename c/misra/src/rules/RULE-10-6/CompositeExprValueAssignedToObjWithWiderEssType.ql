/**
 * @id c/misra/composite-expr-value-assigned-to-obj-with-wider-ess-type
 * @name RULE-10-6: The value of a composite expression shall not be assigned to an object with wider essential type
 * @description TODO.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-6
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::compositeExprValueAssignedToObjWithWiderEssTypeQuery()) and
select
