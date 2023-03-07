/**
 * @id c/misra/function-return-condition
 * @name RULE-15-5: A function should have a single point of exit at the end
 * @description Not having a single point of exit in a function can lead to unintentional behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-15-5
 *       maintainability
 *       readability
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from Function func, string message
where
  not isExcluded(func, Statements5Package::functionReturnConditionQuery()) and
  count(ReturnStmt return | return.getEnclosingFunction() = func) > 1 and
  message = "Function has more than on return statement."
  or
  not func.getBlock().getLastStmt() instanceof ReturnStmt and
  message = "The last statement of the function is not a return statement."
select func, message
