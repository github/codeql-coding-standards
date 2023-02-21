/**
 * @id c/misra/loop-iteration-condition
 * @name RULE-15-4: There should be no more than one break or goto statement used to terminate any iteration statement
 * @description 
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-15-4
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, Statements2Package::loopIterationConditionQuery()) and
select
