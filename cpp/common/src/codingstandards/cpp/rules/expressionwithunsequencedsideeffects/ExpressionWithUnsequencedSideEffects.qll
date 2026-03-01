/**
 * Provides a configurable module ExpressionWithUnsequencedSideEffects with a `problems` predicate
 * for the following issue:
 * Code behavior should not have unsequenced or indeterminately sequenced operations on
 * the same memory location.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects
import codingstandards.cpp.Ordering

signature module ExpressionWithUnsequencedSideEffectsConfigSig {
  Query getQuery();

  predicate isUnsequenced(VariableAccess va1, VariableAccess va2);
}

module ExpressionWithUnsequencedSideEffects<ExpressionWithUnsequencedSideEffectsConfigSig Config> {
  query predicate problems(
    FullExpr e, string message, VariableAccess va1, string va1Desc, VariableEffect ve,
    string veDesc, VariableAccess va2, string va2Desc, Variable v, string vName
  ) {
    not isExcluded(e, Config::getQuery()) and
    e = va1.(ConstituentExpr).getFullExpr() and
    va1 = ve.getAnAccess() and
    Config::isUnsequenced(va1, va2) and
    v = va1.getTarget() and
    message =
      "The evaluation is depended on the order of evaluation of $@, that is modified by $@ and $@, that both access $@." and
    va1Desc = "sub-expression" and
    veDesc = "expression" and
    va2Desc = "sub-expression" and
    vName = v.getName()
  }
}
