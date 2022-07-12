/**
 * @id c/cert/assignments-in-selection-statements
 * @name EXP45-C: Do not perform assignments in selection statements
 * @description Assignments in selection statements is indicative of a programmer error and can
 *              result in unexpected program behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/exp45-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Expr

Expr getRightMostOperand(CommaExpr e) {
  result = e.getRightOperand() and not result instanceof CommaExpr
  or
  result = getRightMostOperand(e.getRightOperand())
}

class SelectionExpr extends Expr {
  SelectionExpr() {
    exists(Expr selection |
      exists(ControlStructure cs | cs.getControllingExpr() = selection)
      or
      exists(ConditionalExpr ce | ce.getCondition() = selection)
      or
      exists(LogicalAndExpr land | land.getAnOperand() = selection)
      or
      exists(LogicalOrExpr lor | lor.getAnOperand() = selection)
    |
      if selection instanceof CommaExpr
      then this = getRightMostOperand(selection)
      else
        if selection instanceof ConditionalExpr
        then
          this = selection.(ConditionalExpr).getThen() or
          this = selection.(ConditionalExpr).getElse()
        else this = selection
    )
  }
}

from AssignExpr e
where
  not isExcluded(e, SideEffects1Package::assignmentsInSelectionStatementsQuery()) and
  exists(SelectionExpr s |
    s.getAChild*() = e and
    // Exclude intentional assignment where the result of the assignment is an operand to a comparison
    // expression.
    not any(ComparisonOperation op).getAnOperand() = e and
    // Exclude an assignment where the expression consists of a single primary expression.
    not (e instanceof PrimaryExpr and not e.getParent() instanceof Expr) and
    // Exclude assignments that are a function argument.
    not any(FunctionCall c).getAnArgument() = e and
    // Exclude assignments used in an array index.
    not any(ArrayExpr ae).getArrayOffset() = e
  )
select e, "Assignment in selection statement."
