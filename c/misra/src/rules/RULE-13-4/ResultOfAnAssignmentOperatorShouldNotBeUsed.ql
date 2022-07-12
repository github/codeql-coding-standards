/**
 * @id c/misra/result-of-an-assignment-operator-should-not-be-used
 * @name RULE-13-4: The result of an assignment operator should not be used
 * @description The use of an assignment operator can impair the readability of the code and the
 *              introduced side effect may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-13-4
 *       correctness
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from AssignExpr e
where
  not isExcluded(e, SideEffects1Package::resultOfAnAssignmentOperatorShouldNotBeUsedQuery()) and
  not exists(ExprStmt s | s.getExpr() = e)
select e, "Use of an assignment operator's result."
