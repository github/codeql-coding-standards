/**
 * @id c/misra/selection-compound-condition
 * @name RULE-15-6: the statement forming the body of a loop shall be a compound statement
 * @description if the body of a selection statement is not enclosed in braces, then this can lead
 *              to incorrect execution, and is hard for developers to maintain.
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

from IfStmt ifStmt
where
  not isExcluded(ifStmt, Statements3Package::selectionCompoundConditionQuery()) and
  not ifStmt.getChildStmt() instanceof BlockStmt
select ifStmt, "If statement not enclosed within braces."
