/**
 * @id c/misra/sizeof-operand-with-side-effect
 * @name RULE-13-6: The operand of the sizeof operator shall not contain any expression which has potential side effects
 * @description The operand to sizeof is not evaluated and its side effect will not be generated.
 *              Using an operand with a side effect can result in unexpected program behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-13-6
 *       correctness
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Variable
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects
import codingstandards.cpp.sideeffect.Customizations

class FunctionCallEffect extends GlobalSideEffect::Range {
  FunctionCallEffect() { this instanceof FunctionCall }
}

class CrementEffect extends LocalSideEffect::Range {
  CrementEffect() { this instanceof CrementOperation }
}

from SizeofExprOperator op, Expr operand, SideEffect effect
where
  not isExcluded(op, SideEffects1Package::sizeofOperandWithSideEffectQuery()) and
  operand = op.getExprOperand() and
  effect = getASideEffect(operand) and
  // Exclude side-effects in called functions because we already consider any
  // function call to generate side-effects in line with the rule.
  not exists(FunctionCall call |
    operand.getAChild*() = call and getASideEffectInFunction(call.getTarget()) = effect
  ) and
  (
    effect.(VariableAccess).getTarget().isVolatile()
    implies
    effect.(VariableAccess).getTarget() instanceof VlaVariable
  )
select op, "The sizeof $@ is not evaluated but has a potential $@.", operand, "operand", effect,
  "side effect"
