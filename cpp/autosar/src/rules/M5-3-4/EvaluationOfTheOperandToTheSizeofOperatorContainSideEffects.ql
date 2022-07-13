/**
 * @id cpp/autosar/evaluation-of-the-operand-to-the-sizeof-operator-contain-side-effects
 * @name M5-3-4: Evaluation of the operand to the sizeof operator shall not contain side effects
 * @description The sizeof operator does not evaluate expressions so reliance on side effects will
 *              result in unexpected behavior.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/m5-3-4
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects

from SizeofExprOperator op, Expr e
where
  not isExcluded(op,
    SideEffects1Package::evaluationOfTheOperandToTheSizeofOperatorContainSideEffectsQuery()) and
  e = op.getExprOperand() and
  hasSideEffect(e)
select op,
  "The sizeof $@ is not evaluated and reliance on its side effects will result in unexpected behavior.",
  e, "operand"
