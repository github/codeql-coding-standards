/**
 * @id cpp/cert/do-not-rely-on-side-effects-in-no-except-operand
 * @name EXP52-CPP: Do not rely on side effects in the operator noexcept
 * @description The noexcept operator does not evaluate expressions so reliance on side effects will
 *              result in unexpected behavior.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags external/cert/id/exp52-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects

from NoExceptExpr e
where
  not isExcluded(e, SideEffects1Package::doNotRelyOnSideEffectsInNoExceptOperandQuery()) and
  hasSideEffect(e) and
  not e.isInMacroExpansion()
select e,
  "Reliance on side effects in the noexcept operator's operand can result in unexpected behavior."
