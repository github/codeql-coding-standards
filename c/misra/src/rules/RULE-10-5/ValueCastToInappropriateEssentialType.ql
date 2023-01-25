/**
 * @id c/misra/value-cast-to-inappropriate-essential-type
 * @name RULE-10-5: The value of an expression should not be cast to an inappropriate essential type
 * @description TODO.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-5
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::valueCastToInappropriateEssentialTypeQuery()) and
select
