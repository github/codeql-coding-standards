/**
 * @id c/misra/pointer-type-on-logical-operator
 * @name RULE-10-1: Logical operators should not be used with pointer types
 * @description Using pointer types with logical operators should be avoid because it can cause
 *              confusing behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-10-1
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from Expr logicalOperator, Expr operand
where
  not isExcluded(operand, EssentialTypesPackage::pointerTypeOnLogicalOperatorQuery()) and
  (
    operand = logicalOperator.(BinaryLogicalOperation).getAnOperand()
    or
    operand = logicalOperator.(NotExpr).getOperand()
  ) and
  operand.getType() instanceof PointerType
select operand, "Logical operators should not be used with pointer types."
