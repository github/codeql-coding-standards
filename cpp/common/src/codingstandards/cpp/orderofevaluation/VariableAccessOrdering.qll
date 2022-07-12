import cpp
import codingstandards.cpp.Ordering

class VariableAccessInFullExpressionOrdering extends Ordering::Configuration {
  VariableAccessInFullExpressionOrdering() { this = "VariableAccessInFullExpressionOrdering" }

  override predicate isCandidate(Expr e1, Expr e2) { isCandidate(_, e1, e2) }
}

pragma[noinline]
private predicate isConstituentOf(FullExpr e, VariableAccess ce) {
  ce.(ConstituentExpr).getFullExpr() = e
}

// Disable magic to prevent a CP between variable accesses
pragma[nomagic]
predicate isCandidatePair(
  FullExpr e, VariableAccess va1, VariableAccess va2, Variable v1, Variable v2
) {
  isConstituentOf(e, va1) and
  isConstituentOf(e, va2) and
  not va1 = va2 and
  va1.getTarget() = v1 and
  va2.getTarget() = v2
}

/**
 * Holds if variable access `va1` and variable access `va2`, part of `e`, are to be considered for order of evaluation validation.
 * Note that this limits candidates to full-expression so we use a few shortcuts to exclude cases where an effect is known to be part of
 * an other full expression that is sequenced after the value computation (and therefore cannot influence them at that point in the evaluation).
 */
predicate isCandidate(FullExpr e, VariableAccess va1, VariableAccess va2) {
  exists(Variable v, VariableEffect ve |
    isCandidatePair(e, va1, va2, v, v) and
    ve.getAnAccess() = va1 and
    not e = ve and
    // Exclude partial effects, such as changing a value of a field or an array entry, because we currently cannot properly
    // match those to determine an unsequenced value computation and side-effects.
    not ve.isPartial() and
    (
      e instanceof Operation and
      // Prevent side-effects that are sequenced after the value computation and side-effects of the candidates.
      // For example, `x = foo(y, &y)` where `foo` modifies `y` through the second argument.
      not exists(Call call |
        call.getAnArgument().getAChild*() = va1 and
        call.getAnArgument().getAChild*() = va2 and
        // if the side-effect occurs in the callee, it is sequenced after the argument value computation.
        call.getTarget().calls*(ve.getEnclosingFunction())
      )
      or
      e instanceof Call and
      // if the side-effect occurs in the callee, it is sequenced after the argument value computation.
      not e.(Call).getTarget().calls*(ve.getEnclosingFunction())
    ) and
    not e.isAffectedByMacro()
  )
}
