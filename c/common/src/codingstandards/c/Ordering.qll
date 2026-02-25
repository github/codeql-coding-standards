import cpp
import codingstandards.c.Expr
import codingstandards.cpp.Variable

module Ordering {
  private import codingstandards.cpp.Ordering as CppCommonOrdering
  import CppCommonOrdering::OrderingBase

  module CConfigBase {
    class EvaluationNode = Expr;

    pragma[inline]
    Expr toExpr(Expr e) { result = e }

    pragma[inline]
    predicate sequencingEdge(Expr e1, Expr e2) { c11Ordering(e1, e2) }
  }

  pragma[inline]
  predicate c11Ordering(Expr e1, Expr e2) {
    // 6.5.2.2 point 10 - The evaluation of the function designator and the actual arguments are sequenced
    // before the actual call.
    exists(Call call |
      (
        call.getAnArgument().getAChild*() = e1
        or
        // Postfix expression designating the called function
        // We current only handle call through function pointers because the postfix expression
        // of regular function calls is not available. That is, identifying `f` in `f(...)`
        call.(ExprCall).getExpr().getAChild*() = e1
      ) and
      call.getTarget() = e2.getEnclosingFunction()
    )
    or
    // 6.5.13 point 4 & 6.5.14 point 4 - The operators guarantee left-to-right evaluation and there is
    // a sequence point between the first and second operand if the latter is evaluated.
    exists(BinaryLogicalOperation blop |
      blop instanceof LogicalAndExpr or blop instanceof LogicalOrExpr
    |
      blop.getLeftOperand().getAChild*() = e1 and blop.getRightOperand().getAChild*() = e2
    )
    or
    // 6.5.17 point 2 - There is a sequence point between the left operand and the right operand.
    exists(CommaExpr ce, Expr lhs, Expr rhs |
      lhs = ce.getLeftOperand() and
      rhs = ce.getRightOperand()
    |
      lhs.getAChild*() = e1 and rhs.getAChild*() = e2
    )
    or
    // 6.5.15 point 4 - There is a sequence point between the first operand and the evaluation of the second or third.
    exists(ConditionalExpr cond |
      cond.getCondition().getAChild*() = e1 and
      (cond.getThen().getAChild*() = e2 or cond.getElse().getAChild*() = e2)
    )
    or
    // Between the evaluation of a full expression and the next to be evaluated full expression.
    // Note we don't strictly check if `e2` is the next to be evaluated full expression and rely on the
    // `isCandidate` configuration to minimze the scope or related full expressions.
    e1 instanceof FullExpr and e2 instanceof FullExpr
    or
    // The side effect of updating the stored value of the left operand is sequenced after the value computations of the left and right operands.
    // See 6.5.16
    e2.(Assignment).getAnOperand().getAChild*() = e1
    or
    // There is a sequence point after a full declarator as described in 6.7.6 point 3.
    exists(DeclStmt declStmt, int i, int j | i < j |
      declStmt
          .getDeclarationEntry(i)
          .(VariableDeclarationEntry)
          .getVariable()
          .getInitializer()
          .getExpr()
          .getAChild*() = e1 and
      declStmt
          .getDeclarationEntry(j)
          .(VariableDeclarationEntry)
          .getVariable()
          .getInitializer()
          .getExpr()
          .getAChild*() = e2
    )
  }
}
