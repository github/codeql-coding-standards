/**
 * @id c/misra/non-boolean-if-condition
 * @name RULE-14-4: The condition of an if-statement shall have type bool
 * @description Non boolean conditions can be confusing for developers.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-14-4
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.nonbooleanifstmt.NonBooleanIfStmt

class NonBooleanIfConditionQuery extends NonBooleanIfStmtSharedQuery {
  NonBooleanIfConditionQuery() {
    this = Statements4Package::nonBooleanIfConditionQuery()
  }
}
