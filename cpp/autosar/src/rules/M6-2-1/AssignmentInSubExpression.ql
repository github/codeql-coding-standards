/**
 * @id cpp/autosar/assignment-in-sub-expression
 * @name M6-2-1: Assignment operators shall not be used in sub-expressions
 * @description Assigning values in a sub-expression add additional side-effects that potentially
 *              results in values inconsistent with the developers expectations.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m6-2-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SideEffect
import codingstandards.cpp.Expr

from AssignExpr assignment
where
  not isExcluded(assignment, OrderOfEvaluationPackage::assignmentInSubExpressionQuery()) and
  not assignment instanceof FullExpr and
  not assignment.isInMacroExpansion() and
  // Exclude assignments of the form x = 1, y = 2, z = 3 because the `=` cannot be confused by `==` between
  // operands of the comma operator.
  not assignment.getParent() instanceof CommaExpr
select assignment, "Use of assignment operator in $@.", assignment.getParent(), "sub-expression"
