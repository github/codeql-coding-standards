/**
 * @id c/misra/loop-compound-condition
 * @name RULE-15-6: the statement forming the body of a loop shall be a compound statement
 * @description if the body of a loop is not enclosed in braces, then this can lead to incorrect
 *              execution, and is hard for developers to maintain.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-15-6
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from Loop loop
where
  not isExcluded(loop, Statements3Package::loopCompoundConditionQuery()) and
  not loop.getStmt() instanceof BlockStmt
select loop, "Loop body not enclosed within braces."
