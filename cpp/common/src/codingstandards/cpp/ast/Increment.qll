import cpp

abstract class LegacyForLoopUpdateExpression extends Expr {
  ForStmt forLoop;

  LegacyForLoopUpdateExpression() { this = forLoop.getUpdate().getAChild*() }

  abstract Expr getLoopStep();
  /* TODO: Complete below and use it for 3-2 */
  // abstract VariableAccess getUpdatedVariable();
}

class CrementLegacyForLoopUpdateExpression extends LegacyForLoopUpdateExpression {
  CrementLegacyForLoopUpdateExpression() { this instanceof CrementOperation }

  override Expr getLoopStep() { none() }
}

class AssignAddOrSubExpr extends LegacyForLoopUpdateExpression {
  AssignAddOrSubExpr() {
    this instanceof AssignAddExpr or
    this instanceof AssignSubExpr
  }

  override Expr getLoopStep() {
    result = this.(AssignAddExpr).getRValue() or
    result = this.(AssignSubExpr).getRValue()
  }
}

class AddOrSubThenAssignExpr extends LegacyForLoopUpdateExpression {
  Expr assignRhs;

  AddOrSubThenAssignExpr() {
    this.(AssignExpr).getRValue() = assignRhs and
    (
      assignRhs instanceof AddExpr or
      assignRhs instanceof SubExpr
    )
  }

  override Expr getLoopStep() {
    (
      result = assignRhs.(AddExpr).getAnOperand() or
      result = assignRhs.(SubExpr).getAnOperand()
    ) and
    exists(VariableAccess iterationVariableAccess |
      (
        iterationVariableAccess = assignRhs.(AddExpr).getAnOperand()
        or
        iterationVariableAccess = assignRhs.(SubExpr).getAnOperand()
      ) and
      iterationVariableAccess.getTarget() = forLoop.getAnIterationVariable() and
      result != iterationVariableAccess
    )
  }
}