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

class VariableEffectOrAccess extends Expr {
  VariableEffectOrAccess() {
    this instanceof VariableEffect or
    this instanceof VariableAccess
  }
}

pragma[noinline]
predicate partOfFullExpr(VariableEffectOrAccess e, FullExpr fe) {
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

predicate sameFullExpr(FullExpr fe, VariableAccess va1, VariableAccess va2) {
  partOfFullExpr(va1, fe) and
  partOfFullExpr(va2, fe) and
  va1 != va2 and
  exists(Variable v1, Variable v2 |
    // Use `pragma[only_bind_into]` to prevent CP between variable accesses.
    va1.getTarget() = pragma[only_bind_into](v1) and va2.getTarget() = pragma[only_bind_into](v2)
  |
    v1.isVolatile() and v2.isVolatile()
    or
    not (v1.isVolatile() and v2.isVolatile()) and
    v1 = v2
  )
}

from
  ConstituentExprOrdering orderingConfig, FullExpr fullExpr, VariableEffect variableEffect1,
  VariableAccess va1, VariableAccess va2, Locatable placeHolder, string label
where
  not isExcluded(fullExpr, SideEffects3Package::unsequencedSideEffectsQuery()) and
  // The two access are scoped to the same full expression.
  sameFullExpr(fullExpr, va1, va2) and
  // We are only interested in effects that change an object,
  // i.e., exclude patterns suchs as `b->data[b->cursor++]` where `b` is considered modified and read or `foo.bar = 1` where `=` modifies to both `foo` and `bar`.
  not variableEffect1.isPartial() and
  variableEffect1.getAnAccess() = va1 and
  (
    exists(VariableEffect variableEffect2 |
      not variableEffect2.isPartial() and
      variableEffect2.getAnAccess() = va2 and
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
      // Break the symmetry of the ordering relation by requiring that the first expression is located before the second.
      // This builds upon the assumption that the expressions are part of the same full expression as specified in the ordering configuration.
      exists(int offset1, int offset2 |
        va1.getLocation().charLoc(_, offset1, _) and
        va2.getLocation().charLoc(_, offset2, _) and
        offset1 < offset2
      ) and
      placeHolder = variableEffect2 and
      label = "side effect"
    )
    or
    placeHolder = va2 and
    label = "read" and
    not exists(VariableEffect variableEffect2 | variableEffect1 != variableEffect2 |
      variableEffect2.getAnAccess() = va2
    ) and
    (
      va1.getEnclosingStmt() = variableEffect1.getEnclosingStmt() and
      orderingConfig.isUnsequenced(variableEffect1, va2)
      or
      not va1.getEnclosingStmt() = variableEffect1.getEnclosingStmt() and
      exists(Call call |
        call.getAnArgument() = va1 and call.getEnclosingStmt() = va2.getEnclosingStmt()
      |
        orderingConfig.isUnsequenced(call, va2)
      )
    ) and
    // The read is not used to compute the effect on the variable.
    // E.g., exclude x = x + 1
    not variableEffect1.getAChild+() = va2
  ) and
  // Both are evaluated
  not exists(ConditionalExpr ce |
    ce.getThen().getAChild*() = va1 and ce.getElse().getAChild*() = va2
  )
select fullExpr, "The expression contains unsequenced $@ to $@ and $@ to $@.", variableEffect1,
  "side effect", va1, va1.getTarget(), placeHolder, label, va2, va2.getTarget()
