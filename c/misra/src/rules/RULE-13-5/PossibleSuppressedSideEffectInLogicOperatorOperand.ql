/**
 * @id c/misra/possible-suppressed-side-effect-in-logic-operator-operand
 * @name RULE-13-5: The right hand operand of a logical && or || operator shall not contain persistent side effects
 * @description The evaluation of the right-hand operand of the && and || operators is conditional
 *              on the value of the left-hand operand. Any side effects in the right-hand operand
 *              may or may not occur and may result in unexpected program behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-13-5
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects

from BinaryLogicalOperation blop, SideEffect s
where
  not isExcluded(blop,
    SideEffects1Package::possibleSuppressedSideEffectInLogicOperatorOperandQuery()) and
  s = getAnExternalOrGlobalSideEffect(blop.getRightOperand())
select blop, "The right hand operand generates the persistent $@", s, "side effect"
