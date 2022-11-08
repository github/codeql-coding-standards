/**
 * @id c/misra/value-returned-by-a-function-not-used
 * @name RULE-17-7: The value returned by a function having non-void return type shall be used
 * @description 
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-17-7
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, Contracts6Package::valueReturnedByAFunctionNotUsedQuery()) and
select
