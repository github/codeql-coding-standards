/**
 * @id c/misra/assignment-to-incompatible-essential-type
 * @name RULE-10-3: The value of an expression shall not be assigned to an object with a narrower essential type or of a
 * @description The value of an expression shall not be assigned to an object with a narrower
 *              essential type or of a different essential type category.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-10-3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::assignmentToIncompatibleEssentialTypeQuery()) and
select
