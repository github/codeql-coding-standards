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

predicate isCandidatePair(Expr parentExpr, Expr e1, Expr e2) {
  parentExpr.getAChild+() = e1 and
  parentExpr.getAChild+() = e2
}

class ConstituentExprOrdering extends Ordering::Configuration {
  ConstituentExprOrdering() { this = "ConstituentExprOrdering" }

  override predicate isCandidate(Expr e1, Expr e2) {
    // Two different expressions part of the same full expression.
    isCandidatePair(_, e1, e2)
  }
}

from
  ConstituentExprOrdering orderingConfig, FullExpr fullExpr, VariableEffect variableEffect1,
  VariableEffect variableEffect2
where
  not isExcluded(fullExpr, SideEffects3Package::unsequencedSideEffectsQuery()) and
  // If the effect is local we can directly check if it is unsequenced.
  // If the effect is not local (happens in a different function) we use the access as a proxy.
  orderingConfig.isUnsequenced(variableEffect1, variableEffect2) and
  fullExpr.getAChild+() = variableEffect1 and
  fullExpr.getAChild+() = variableEffect2 and
  // Both are evaluated
  not exists(ConditionalExpr ce |
    ce.getThen().getAChild*() = variableEffect1 and ce.getElse().getAChild*() = variableEffect2
  ) and
  // Break the symmetry of the ordering relation by requiring that the first expression is located before the second.
  // This builds upon the assumption that the expressions are part of the same full expression as specified in the ordering configuration.
  exists(int offset1, int offset2 |
    variableEffect1.getLocation().charLoc(_, offset1, _) and
    variableEffect2.getLocation().charLoc(_, offset2, _) and
    offset1 < offset2
  )
select fullExpr, "The expression contains unsequenced $@ to $@ and $@ to $@.", variableEffect1,
  "side effect", variableEffect1.getAnAccess(), variableEffect1.getTarget().getName(),
  variableEffect2, "side effect", variableEffect2.getAnAccess(),
  variableEffect2.getTarget().getName()
