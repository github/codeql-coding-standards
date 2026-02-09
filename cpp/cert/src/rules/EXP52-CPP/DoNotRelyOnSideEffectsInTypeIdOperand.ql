/**
 * @id cpp/cert/do-not-rely-on-side-effects-in-type-id-operand
 * @name EXP52-CPP: Do not rely on side effects in the operator typeid
 * @description The typeid operator does not always evaluate expressions so reliance on side effects
 *              will result in unexpected behavior.
 * @kind problem
 * @precision very-high
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

from TypeidOperator op, FunctionCall call
where
  not isExcluded(op, SideEffects1Package::doNotRelyOnSideEffectsInTypeIdOperandQuery()) and
  op.getExpr() = call and
  not op.isInMacroExpansion()
select op,
  "The typeid operand is the function call to $@ and reliance on its side effects can result in unexpected behavior",
  call.getTarget(), call.getTarget().getName()
