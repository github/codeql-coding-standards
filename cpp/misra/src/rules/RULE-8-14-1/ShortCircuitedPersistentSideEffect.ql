/**
 * @id cpp/misra/short-circuited-persistent-side-effect
 * @name RULE-8-14-1: The right-hand operand of a logical && or || operator should not contain persistent side effects
 * @description The right-hand operand of a logical && or || operator should not contain persistent
 *              side effects, as such side effects will only conditionally occur, which may violate
 *              developer intent and/or expectations.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-8-14-1
 *       scope/system
 *       correctness
 *       readability
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.shortcircuitedpersistentsideeffectshared.ShortCircuitedPersistentSideEffectShared

module ShortCircuitedPersistentSideEffectConfig implements
  ShortCircuitedPersistentSideEffectSharedConfigSig
{
  Query getQuery() { result = SideEffects5Package::shortCircuitedPersistentSideEffectQuery() }
}

import ShortCircuitedPersistentSideEffectShared<ShortCircuitedPersistentSideEffectConfig>
