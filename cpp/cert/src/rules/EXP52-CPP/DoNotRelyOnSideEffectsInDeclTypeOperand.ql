/**
 * @id cpp/cert/do-not-rely-on-side-effects-in-decl-type-operand
 * @name EXP52-CPP: Do not rely on side effects in the operator decltype
 * @description The decltype operator does not evaluate expressions so reliance on side effects will
 *              result in unexpected behavior.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags external/cert/id/exp52-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p3
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Sfinae
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects

from Decltype t, SideEffect e
where
  not isExcluded(t, SideEffects1Package::doNotRelyOnSideEffectsInDeclTypeOperandQuery()) and
  e = getASideEffect(t.getExpr()) and
  not t.isInMacroExpansion() and
  not isInSFINAEContext(t)
select t, "Reliance on $@ in the decltype operator can result in unexpected behavior.", e,
  "side effect"
