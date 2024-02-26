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
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects

/**
 * an operator that does not evaluate its operand
 * `decltype` also has a non evaluated operand but cannot be used in a `BinaryLogicalOperation`
 */
class UnevaluatedOperand extends Expr {
  Expr operator;

  UnevaluatedOperand() {
    exists(SizeofExprOperator op | op.getExprOperand() = this |
      not this.getUnderlyingType().(ArrayType).hasArraySize() and
      operator = op
    )
    or
    exists(NoExceptExpr e |
      e.getExpr() = this and
      operator = e
    )
    or
    exists(TypeidOperator t |
      t.getExpr() = this and
      operator = t
    )
    or
    exists(FunctionCall declval |
      declval.getTarget().hasQualifiedName("std", "declval") and
      declval.getAChild() = this and
      operator = declval
    )
  }

  Expr getOp() { result = operator }
}

from BinaryLogicalOperation op, Expr rhs
where
  not isExcluded(op,
    SideEffects1Package::rightHandOperandOfALogicalAndOperatorsContainSideEffectsQuery()) and
  rhs = op.getRightOperand() and
  hasSideEffect(rhs) and
  not exists(UnevaluatedOperand un | un.getOp() = rhs)
select op, "The $@ may have a side effect that is not always evaluated.", rhs, "right-hand operand"
