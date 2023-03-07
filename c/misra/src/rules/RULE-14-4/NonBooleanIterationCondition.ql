/**
 * @id c/misra/non-boolean-iteration-condition
 * @name RULE-14-4: The condition of an iteration statement shall have type bool
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
import codingstandards.cpp.rules.nonbooleaniterationstmt.NonBooleanIterationStmt

class NonBooleanIterationConditionQuery extends NonBooleanIterationStmtSharedQuery {
  NonBooleanIterationConditionQuery() {
    this = Statements4Package::nonBooleanIterationConditionQuery()
  }
}
