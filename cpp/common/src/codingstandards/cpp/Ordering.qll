import cpp
import codingstandards.cpp.Expr
import codingstandards.cpp.SideEffect

module OrderingBase {
  signature module ConfigSig {
    class EvaluationNode;

    Expr toExpr(EvaluationNode n);

    predicate isCandidate(Expr e1, Expr e2);

    predicate sequencingEdge(EvaluationNode n1, EvaluationNode n2);
  }

  module Make<ConfigSig Config> {
    predicate isSequencedBefore(Expr e1, Expr e2) {
      exists(Config::EvaluationNode n1, Config::EvaluationNode n2 |
        Config::toExpr(n1) = e1 and Config::toExpr(n2) = e2
      |
        edge(n1, n2)
      )
    }

    predicate isUnsequenced(Expr e1, Expr e2) {
      Config::isCandidate(e1, e2) and
      not isSequencedBefore(e1, e2) and
      not isSequencedBefore(e2, e1)
    }

    private predicate edge(Config::EvaluationNode n1, Config::EvaluationNode n2) {
      Config::isCandidate(Config::toExpr(n1), Config::toExpr(n2)) and
      not n1 = n2 and
      Config::sequencingEdge(n1, n2)
    }
  }
}

module Ordering {
  import OrderingBase

  module CppConfigBase {
    class EvaluationNode = ExprEvaluationNode;

    pragma[inline]
    Expr toExpr(EvaluationNode n) { result = n.toExpr() }
  }

  pragma[inline]
  predicate cpp14Edge(ExprEvaluationNode n1, ExprEvaluationNode n2) {
    // [intro.execution] - Each value computation and side effect of a full expression is sequenced
    // before each value computation and side effect of the next full expression.
    exists(FullExpr e1, FullExpr e2 | e1 = n1.toExpr() and e2 = n2.toExpr())
    or
    // [intro.execution] - The value computations of the operands to any operator are sequenced before
    // the value computation of the result of the operator.
    exists(Operation op |
      op.getAnOperand() = n1.toExpr() and
      op = n2.toExpr() and
      n1.isValueComputation() and
      n2.isValueComputation()
    )
    or
    // [intro.execution] - Every value computation and side effect associated with any argument
    // expression, or with the postfix expression designating the called function, of a function call
    // is sequenced before every expression or statement in the body of the called function.
    exists(Call call |
      (
        call.getAnArgument() = n1.toExpr()
        or
        // Postfix expression designating the called function
        // We current only handle call through function pointers because the postfix expression
        // of regular function calls is not available. That is, identifying `f` in `f(...)`
        call.(ExprCall).getExpr() = n1.toExpr()
      ) and
      call.getTarget() = n2.toExpr().getEnclosingFunction()
    )
    or
    // [expr.post.incr] - The value computation of the ++ expression is sequenced before the modification of the operand object.
    exists(PostfixCrementOperation op |
      op = n1.toExpr() and op = n2.toExpr() and n1.isValueComputation() and n2.isSideEffect()
    )
    or
    // The side effect of the builtin pre-increment and pre-decrement operators is sequenced before its value computation.
    exists(PrefixCrementOperation op |
      op = n1.toExpr() and op = n2.toExpr() and n1.isSideEffect() and n2.isValueComputation()
    )
    or
    // [expr.log.and] - If the second expression is evaluated, every value computation and side effect associated with
    // the first expression is sequenced before every value computation and side effect associated with
    // the second exression.
    exists(LogicalAndExpr land |
      land.getLeftOperand() = n1.toExpr() and land.getRightOperand() = n2.toExpr()
    )
    or
    // [expr.log.or] - If the second expression is evaluated, every value computation and side effect associated with
    // the first expression is sequenced before every value computation and side effect associated with
    // the second exression
    exists(LogicalOrExpr lor |
      lor.getLeftOperand() = n1.toExpr() and lor.getRightOperand() = n2.toExpr()
    )
    or
    // [expr.cond] - Every value computation and side effect associated with the first expression is sequenced before
    // every value computation and side effect associated with the second or third expression.
    exists(ConditionalExpr cond |
      cond.getCondition() = n1.toExpr() and
      (cond.getThen() = n2.toExpr() or cond.getElse() = n2.toExpr())
    )
    or
    // [expr.comma] - Every value computation and side effect assocatiated with the left expression
    // is sequenced before every value computation and side effect associated with the right expression.
    exists(CommaExpr ce, ConstituentExpr lhs, ConstituentExpr rhs |
      lhs = ce.getLeftOperand() and
      rhs = ce.getRightOperand()
    |
      lhs = n1.toExpr().getParent*() and rhs = n2.toExpr().getParent*()
    )
    or
    // [dcl.init.list] - Every value computation and side effect associated with any initializer-clause
    // is sequenced before every value computation and side effect associaed with any initializer-clause
    // that follows it in the comma-separated list of the initializer-list
    exists(AggregateLiteral l, ConstituentExpr lhs, ConstituentExpr rhs, int i, int j |
      lhs = l.getChild(i) and
      rhs = l.getChild(j) and
      i < j
    |
      lhs = n1.toExpr().getParent*() and rhs = n2.toExpr().getParent*()
    )
  }

  pragma[inline]
  predicate cpp17Edge(ExprEvaluationNode n1, ExprEvaluationNode n2) {
    cpp14Edge(n1, n2)
    or
    // [expr.call] The "postfix expression" (the part before the `(...)`) is sequenced before each
    // expression in the expression list.
    exists(Call call, Expr qual, Expr arg |
      call.getQualifier() = qual and
      call.getAnArgument() = arg
      |
      qual = n1.toExpr().getParent*() and arg = n2.toExpr().getParent*()
    )
    or
    // [expr.sub] - (in) the expression E1[E2] ... E1 is sequenced before E2
    exists(ArrayExpr ce, ConstituentExpr lhs, ConstituentExpr rhs |
      lhs = ce.getArrayBase() and
      rhs = ce.getArrayOffset()
    |
      lhs = n1.toExpr().getParent*() and rhs = n2.toExpr().getParent*()
    )
    or
    // [expr.new] -- invocation of the allocation function is sequenced before the expressions in
    // the new-initializer.
    exists(NewExpr newExpr, ConstituentExpr alloc, ConstituentExpr arg |
      alloc = newExpr.getAllocatorCall() and
      arg = newExpr.getInitializer().getAChild()
    |
      alloc = n1.toExpr().getParent*() and
      arg = n2.toExpr().getParent*()
    )
    or
    // [expr.mptr.oper] - In E.*E2, E1 is sequenced before E2. This is not the case for E->*E2.
    exists(PointerToMemberExpr ptrToMember, ConstituentExpr object, ConstituentExpr ptr |
      // TODO: distinguish between `.*` and `->*` operators.
      object = ptrToMember.getObjectExpr() and
      ptr = ptrToMember.getPointerExpr()
    |
      object = n1.toExpr().getParent*() and ptr = n2.toExpr().getParent*()
    )
    or
    // [expr.shift] In E1 << E2 and E1 >> E2, E1 is sequenced before E2.
    exists(BitShiftExpr shift, ConstituentExpr lhs, ConstituentExpr rhs |
      lhs = shift.getLeftOperand() and
      rhs = shift.getRightOperand()
    |
      lhs = n1.toExpr().getParent*() and rhs = n2.toExpr().getParent*()
    )
    or
    // [expr.ass] The right operand is sequenced before the left operand for all assignment operators.
    exists(Assignment assign, ConstituentExpr lhs, ConstituentExpr rhs |
      lhs = assign.getLValue() and
      rhs = assign.getRValue()
    |
      lhs = n1.toExpr().getParent*() and rhs = n2.toExpr().getParent*()
    )
  }

  private newtype TExprEvaluationNode =
    TValueComputationNode(Expr e) or
    TSideEffectNode(Expr e, SideEffect s) { s = getAnEffect(e) }

  class ExprEvaluationNode extends TExprEvaluationNode {
    Expr toExpr() {
      this = TValueComputationNode(result)
      or
      this = TSideEffectNode(result, _)
    }

    string toString() {
      exists(Expr e |
        this = TValueComputationNode(e) and result = "value computation of " + e.toString()
      )
      or
      exists(Expr e, SideEffect s |
        this = TSideEffectNode(e, s) and
        result = "side effect " + s.toString() + " on " + e.toString()
      )
    }

    predicate isValueComputation() { this = TValueComputationNode(_) }

    predicate isSideEffect() { this = TSideEffectNode(_, _) }

    Location getLocation() { result = toExpr().getLocation() }
  }

}
