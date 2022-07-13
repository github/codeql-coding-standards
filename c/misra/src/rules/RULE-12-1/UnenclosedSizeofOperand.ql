/**
 * @id c/misra/unenclosed-sizeof-operand
 * @name RULE-12-1: The operand of the sizeof operator should be enclosed in parentheses
 * @description The relative precedences of operators are not intuitive and can lead to mistakes.
 *              The use of parentheses to make the precedence of operators explicit removes the
 *              possibility of incorrect expectations.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-12-1
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from SizeofExprOperator op
where
  not isExcluded(op, SideEffects1Package::unenclosedSizeofOperandQuery()) and
  not op.getExprOperand().isParenthesised()
select op, "The operand of the sizeof operator is not enclosed in parentheses."
