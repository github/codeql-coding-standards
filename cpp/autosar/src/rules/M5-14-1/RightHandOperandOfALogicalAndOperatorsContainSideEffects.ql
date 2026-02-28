/**
 * @id cpp/autosar/right-hand-operand-of-a-logical-and-operators-contain-side-effects
 * @name M5-14-1: The right hand operand of a logical &&, || operators shall not contain side effects
 * @description The evaluation of the right hand operand of the logical && and || operators depends
 *              on the left hand operand so reliance on side effects will result in unexpected
 *              behavior.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/m5-14-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.shortcircuitedpersistentsideeffectshared.ShortCircuitedPersistentSideEffectShared

module RightHandOperandOfALogicalAndOperatorsContainSideEffectsConfig implements
  ShortCircuitedPersistentSideEffectSharedConfigSig
{
  Query getQuery() {
    result = SideEffects1Package::rightHandOperandOfALogicalAndOperatorsContainSideEffectsQuery()
  }
}

import ShortCircuitedPersistentSideEffectShared<RightHandOperandOfALogicalAndOperatorsContainSideEffectsConfig>
