/**
 * @id c/misra/array-function-argument-number-of-elements
 * @name RULE-17-5: The function argument corresponding to a parameter declared to have an array type shall have an
 * @description The function argument corresponding to a parameter declared to have an array type
 *              shall have an appropriate number of elements
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-17-5
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, Contracts6Package::arrayFunctionArgumentNumberOfElementsQuery()) and
select
