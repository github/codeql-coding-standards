/**
 * @id cpp/cert/do-not-rely-on-side-effects-in-size-of-operand
 * @name EXP52-CPP: Do not rely on side effects in the operator sizeof
 * @description The sizeof operator does not evaluate expressions so reliance on side effects will
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
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects

from SizeofExprOperator op
where
  not isExcluded(op, SideEffects1Package::doNotRelyOnSideEffectsInSizeOfOperandQuery()) and
  hasSideEffect(op) and
  not op.isInMacroExpansion()
select op,
  "The sizeof operand is not evaluated and reliance on its side effects will result in unexpected behavior."
