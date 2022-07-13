/**
 * @id cpp/autosar/evaluation-of-the-operand-to-the-typeid-operator-contain-side-effects
 * @name A5-3-1: Evaluation of the operand to the typeid operator shall not contain side effects
 * @description The operand of the typeid may or may not be evaluated if it is a function call and
 *              reliance on side effects will result in unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a5-3-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from TypeidOperator op, FunctionCall call
where
  not isExcluded(op,
    SideEffects1Package::evaluationOfTheOperandToTheTypeidOperatorContainSideEffectsQuery()) and
  op.getExpr() = call
select op,
  "The typeid operand is a call to $@ which may or may not be evaluated depending on whether it returns a polymorphic type.",
  call.getTarget(), call.getTarget().getName()
