/**
 * @id c/cert/unevaluated-operand-with-side-effect
 * @name EXP44-C: Do not rely on side effects in operands to sizeof, _Alignof, or _Generic
 * @description The operands to sizeof, _Alignof, or _Generic are not evaluated and their side
 *              effect will not be generated. Using operands with a side effect can result in
 *              unexpected program behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/exp44-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects

class UnevaluatedOperand extends Expr {
  UnevaluatedOperand() {
    exists(SizeofExprOperator op | op.getExprOperand() = this |
      not this.getUnderlyingType().(ArrayType).hasArraySize()
    )
    or
    exists(AlignofExprOperator op | op.getExprOperand() = this)
  }
}

from UnevaluatedOperand op
where
  not isExcluded(op, SideEffects1Package::unevaluatedOperandWithSideEffectQuery()) and
  hasSideEffect(op)
select op, "Unevaluated operand with side effect that will not be generated."
