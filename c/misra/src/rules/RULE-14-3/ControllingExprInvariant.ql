/**
 * @id c/misra/controlling-expr-invariant
 * @name RULE-14-3: Controlling expressions shall not be invariant
 * @description If a controlling expression has an invariant value then it is possible that there is
 *              a programming error.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-14-3
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import cpp
import codingstandards.c.misra

class InvariantExpr extends Expr {
  InvariantExpr() { conditionAlwaysFalse(this) or conditionAlwaysTrue(this) }
}

from InvariantExpr invariantControllingExpr, string message
where
  not isExcluded(invariantControllingExpr, Statements5Package::controllingExprInvariantQuery()) and
  (
    any(IfStmt ifStmt).getControllingExpr() = invariantControllingExpr and
    message = "Controlling expression in if statement has invariant value."
    or
    any(Loop loop).getControllingExpr() = invariantControllingExpr and
    message = "Controlling expression in loop statement has invariant value."
    or
    any(SwitchStmt switchStmt).getControllingExpr() = invariantControllingExpr and
    message = "Controlling expression in switch statement has invariant value."
  )
select invariantControllingExpr, message
