/**
 * Provides a library for working with expressions that update the value
 * of a numeric variable by incrementing or decrementing it by a certain
 * amount.
 */

import cpp

private class AssignAddOrSubExpr extends AssignArithmeticOperation {
  AssignAddOrSubExpr() {
    this instanceof AssignAddExpr or
    this instanceof AssignSubExpr
  }
}

private class AddOrSubExpr extends BinaryArithmeticOperation {
  AddOrSubExpr() {
    this instanceof AddExpr or
    this instanceof SubExpr
  }
}

/**
 * An expression that updates a numeric variable by adding to or subtracting
 * from it a certain amount.
 */
abstract class StepCrementUpdateExpr extends Expr {
  /**
   * The expression in the abstract syntax tree that represents the amount of
   * value by which the variable is updated.
   */
  abstract Expr getAmountExpr();
}

/**
 * An increment or decrement operator application, either postfix or prefix.
 */
class PostfixOrPrefixCrementExpr extends CrementOperation, StepCrementUpdateExpr {
  override Expr getAmountExpr() { none() }
}

/**
 * An add-then-assign or subtract-then-assign expression in a shortened form,
 * i.e. `+=` or `-=`.
 */
class AssignAddOrSubUpdateExpr extends AssignAddOrSubExpr, StepCrementUpdateExpr {
  override Expr getAmountExpr() { result = this.getRValue() }
}

/**
 * An add-then-assign expression or a subtract-then-assign expression, i.e.
 * `x = x + E` or `x = x - E`, where `x` is some variable and `E` an
 * arbitrary expression.
 */
class AddOrSubThenAssignExpr extends AssignExpr, StepCrementUpdateExpr {
  /** The `x` as in the left-hand side of `x = x + E`. */
  VariableAccess lvalueVariable;
  /** The `x + E` as in `x = x + E`. */
  AddOrSubExpr addOrSubExpr;
  /** The `E` as in `x = x + E`. */
  Expr amountExpr;

  AddOrSubThenAssignExpr() {
    this.getLValue() = lvalueVariable and
    this.getRValue() = addOrSubExpr and
    exists(VariableAccess lvalueVariableAsRvalue |
      lvalueVariableAsRvalue = addOrSubExpr.getAnOperand() and
      amountExpr = addOrSubExpr.getAnOperand() and
      lvalueVariableAsRvalue != amountExpr
    |
      lvalueVariable.getTarget() = lvalueVariableAsRvalue.(VariableAccess).getTarget()
    )
  }

  override Expr getAmountExpr() { result = amountExpr }
}
