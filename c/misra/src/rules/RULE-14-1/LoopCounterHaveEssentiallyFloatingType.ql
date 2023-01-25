/**
 * @id c/misra/loop-counter-have-essentially-floating-type
 * @name RULE-14-1: A loop counter shall not have essentially floating type
 * @description TODO.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-14-1
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::loopCounterHaveEssentiallyFloatingTypeQuery()) and
select
