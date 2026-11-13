/**
 * @id c/misra/single-point-of-exit
 * @name RULE-15-5: A function should have a single point of exit at the end
 * @description A single exit can be enforced when this Disapplied guideline is recategorized.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-15-5
 *       maintainability
 *       external/misra/c/2025
 *       external/misra/obligation/disapplied
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.SinglePointOfExit

from Function function, string message, ReturnStmt statement
where
  not isExcluded(function, Statements5Package::singlePointOfExitQuery()) and
  problems(function, message, statement)
select function, message, statement, "return statement"
