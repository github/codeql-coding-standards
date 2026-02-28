/**
 * Provides a configurable module ShortCircuitedPersistentSideEffectShared with a `problems` predicate
 * for the following issue:
 * The right-hand operand of a logical && or || operator should not contain persistent
 * side effects, as this may violate developer intent and expectations.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects
import codingstandards.cpp.Expr

signature module ShortCircuitedPersistentSideEffectSharedConfigSig {
  Query getQuery();
}

module ShortCircuitedPersistentSideEffectShared<
  ShortCircuitedPersistentSideEffectSharedConfigSig Config>
{
  query predicate problems(
    BinaryLogicalOperation op, string message, Expr rhs, string rhsDescription
  ) {
    not isExcluded(op, Config::getQuery()) and
    rhs = op.getRightOperand() and
    hasSideEffect(rhs) and
    not rhs instanceof UnevaluatedExprExtension and
    message = "The $@ may have a side effect that is not always evaluated." and
    rhsDescription = "right-hand operand"
  }
}
