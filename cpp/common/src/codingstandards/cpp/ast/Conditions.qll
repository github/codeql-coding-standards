import cpp
import codeql.util.Boolean

/**
 * Any type of conditional evaluation, such as if statements, and conditional expressions.
 *
 * A condition may be:
 * - An if statement condition
 * - A conditional expression (ternary) condition
 * - A short-circuiting logical expression (&& or ||)
 */
class Conditional extends Element {
  Expr condition;

  Conditional() {
    condition = this.(ConditionalExpr).getCondition()
    or
    condition = this.(IfStmt).getCondition()
    or
    condition = this.(LogicalOrExpr).getLeftOperand()
    or
    condition = this.(LogicalAndExpr).getLeftOperand()
  }

  /**
   * Get the expression that controls the flow of this conditional.
   */
  Expr getCondition() { result = condition }
}
