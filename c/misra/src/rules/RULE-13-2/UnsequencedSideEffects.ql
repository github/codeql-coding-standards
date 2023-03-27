/**
 * @id c/misra/unsequenced-side-effects
 * @name RULE-13-2: The value of an expression and its persistent side effects depend on its evaluation order
 * @description The value of an expression and its persistent side effects are depending on the
 *              evaluation order resulting in unpredictable behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-13-2
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Expr
import codingstandards.c.SideEffects
import codingstandards.c.Ordering

predicate isOrHasSideEffect(Expr e) {
  e instanceof VariableEffect or
  any(VariableEffect ve).getAnAccess() = e
}

predicate partOfFullExpr(Expr e, FullExpr fe) {
  isOrHasSideEffect(e) and
  (
    e.(VariableEffect).getAnAccess() = fe.getAChild+()
    or
    e.(VariableAccess) = fe.getAChild+()
  )
}

class ConstituentExprOrdering extends Ordering::Configuration {
  ConstituentExprOrdering() { this = "ConstituentExprOrdering" }

  override predicate isCandidate(Expr e1, Expr e2) {
    exists(FullExpr fe |
      partOfFullExpr(e1, fe) and
      partOfFullExpr(e2, fe)
    )
  }
}

pragma[noinline]
predicate sameFullExpr(FullExpr fe, Expr e1, Expr e2) {
  partOfFullExpr(e1, fe) and
  partOfFullExpr(e2, fe)
}

predicate destructureEffect(VariableEffect ve, VariableAccess va, Variable v) {
  ve.getAnAccess() = va and
  va.getTarget() = v and
  ve.getTarget() = v
}

from
  ConstituentExprOrdering orderingConfig, FullExpr fullExpr, VariableEffect variableEffect1,
  VariableEffect variableEffect2, VariableAccess va1, VariableAccess va2, Variable v1, Variable v2
where
  not isExcluded(fullExpr, SideEffects3Package::unsequencedSideEffectsQuery()) and
  sameFullExpr(fullExpr, va1, va2) and
  destructureEffect(variableEffect1, va1, v1) and
  destructureEffect(variableEffect2, va2, v2) and
  // Exclude the same effect applying to different objects.
  // This occurs when on is a subject of the other.
  // For example, foo.bar = 1; where both foo and bar are objects modified by the assignment.
  variableEffect1 != variableEffect2 and
  // If the effect is not local (happens in a different function) we use the call with the access as a proxy.
  (
    va1.getEnclosingStmt() = variableEffect1.getEnclosingStmt() and
    va2.getEnclosingStmt() = variableEffect2.getEnclosingStmt() and
    orderingConfig.isUnsequenced(variableEffect1, variableEffect2)
    or
    va1.getEnclosingStmt() = variableEffect1.getEnclosingStmt() and
    not va2.getEnclosingStmt() = variableEffect2.getEnclosingStmt() and
    exists(Call call |
      call.getAnArgument() = va2 and call.getEnclosingStmt() = va1.getEnclosingStmt()
    |
      orderingConfig.isUnsequenced(variableEffect1, call)
    )
    or
    not va1.getEnclosingStmt() = variableEffect1.getEnclosingStmt() and
    va2.getEnclosingStmt() = variableEffect2.getEnclosingStmt() and
    exists(Call call |
      call.getAnArgument() = va1 and call.getEnclosingStmt() = va2.getEnclosingStmt()
    |
      orderingConfig.isUnsequenced(call, variableEffect2)
    )
  ) and
  // Both are evaluated
  not exists(ConditionalExpr ce |
    ce.getThen().getAChild*() = va1 and ce.getElse().getAChild*() = va2
  ) and
  // Break the symmetry of the ordering relation by requiring that the first expression is located before the second.
  // This builds upon the assumption that the expressions are part of the same full expression as specified in the ordering configuration.
  exists(int offset1, int offset2 |
    va1.getLocation().charLoc(_, offset1, _) and
    va2.getLocation().charLoc(_, offset2, _) and
    offset1 < offset2
  )
select fullExpr, "The expression contains unsequenced $@ to $@ and $@ to $@.", variableEffect1,
  "side effect", va1, v1.getName(), variableEffect2, "side effect", va2, v2.getName()
