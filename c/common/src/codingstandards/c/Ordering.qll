import cpp
import codingstandards.cpp.SideEffect
import codingstandards.c.Expr
import codingstandards.cpp.Variable

module Ordering {
  abstract class Configuration extends string {
    bindingset[this]
    Configuration() { any() }

    abstract predicate isCandidate(Expr e1, Expr e2);

    /**
     * Holds if `e1` is sequenced before `e2` as defined by Annex C in ISO/IEC 9899:2011
     * This limits to expression and we do not consider the sequence points that are not amenable to modelling:
     * - after a full declarator as described in 6.7.6 point 3.
     * - before a library function returns (see 7.1.4 point 3).
     * - after the actions associated with each formatted I/O function conversion specifier (see 7.21.6 point 1 & 7.29.2 point 1).
     * - between the expr before and after a call to a comparison function,
     *   between any call to a comparison function, and any movement of the objects passed
     *   as arguments to that call (see 7.22.5 point 5).
     */
    predicate isSequencedBefore(Expr e1, Expr e2) {
      isCandidate(e1, e2) and
      not e1 = e2 and
      (
        // 6.5.2.2 point 10 - The evaluation of the function designator and the actual arguments are sequenced
        // before the actual call.
        exists(Call call |
          (
            call.getAnArgument() = e1
            or
            // Postfix expression designating the called function
            // We current only handle call through function pointers because the postfix expression
            // of regular function calls is not available. That is, identifying `f` in `f(...)`
            call.(ExprCall).getExpr() = e1
          ) and
          call.getTarget() = e2.getEnclosingFunction()
        )
        or
        // 6.5.13 point 4 & 6.5.14 point 4 - The operators guarantee left-to-righ evaluation and there is
        // a sequence point between the first and second operand if the latter is evaluated.
        exists(BinaryLogicalOperation blop |
          blop instanceof LogicalAndExpr or blop instanceof LogicalOrExpr
        |
          blop.getLeftOperand() = e1 and blop.getRightOperand() = e2
        )
        or
        // 6.5.17 point 2 - There is a sequence pointt between the left operand and the right operand.
        exists(CommaExpr ce, Expr lhs, Expr rhs |
          lhs = ce.getLeftOperand() and
          rhs = ce.getRightOperand()
        |
          lhs = e1.getParent*() and rhs = e2.getParent*()
        )
        or
        // 6.5.15 point 4 - There is a sequence point between the first operand and the evaluation of the second or third.
        exists(ConditionalExpr cond |
          cond.getCondition() = e1 and
          (cond.getThen() = e2 or cond.getElse() = e2)
        )
        or
        // Between the evaluation of a full expression and the next to be evaluated full expression.
        // Note we don't strictly check if `e2` is the next to be evaluated full expression and rely on the
        // `isCandidate` configuration to minimze the scope or related full expressions.
        e1 instanceof FullExpr and e2 instanceof FullExpr
      )
    }

    predicate isUnsequenced(Expr e1, Expr e2) {
      isCandidate(e1, e2) and
      not isSequencedBefore(e1, e2) and
      not isSequencedBefore(e2, e1)
    }
  }
}
