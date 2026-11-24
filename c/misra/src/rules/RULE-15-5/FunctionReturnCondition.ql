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
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/legacy
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.SinglePointOfExit

from Function func, string message, ReturnStmt returnStmt
where
  not isExcluded(func, Statements5Package::functionReturnConditionQuery()) and
  problems(func, message, returnStmt)
select func, message, returnStmt, "return statement"
