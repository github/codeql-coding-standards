/**
 * @id cpp/autosar/each-operand-of-the-operator-the-logical-and-or-the-logical-operators-shall-have-type-bool
 * @name M5-3-1: Each operand of the ! operator, the logical && or the logical || operators shall have type bool
 * @description Each operand of the ! operator, the logical && or the logical || operators shall
 *              have type bool.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-3-1
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Expr operand, Type t
where
  not isExcluded(operand,
    OperatorsPackage::eachOperandOfTheOperatorTheLogicalAndOrTheLogicalOperatorsShallHaveTypeBoolQuery()) and
  (
    exists(UnaryLogicalOperation ulo | operand = ulo.getOperand()) or
    exists(BinaryLogicalOperation blo | operand = blo.getAnOperand())
  ) and
  t = operand.getType() and
  not t.getUnderlyingType().getUnspecifiedType() instanceof BoolType and
  not exists(ReferenceType rt |
    rt = t.getUnderlyingType().getUnspecifiedType() and rt.getBaseType() instanceof BoolType
  ) and
  not operand.isFromUninstantiatedTemplate(_)
select operand, "bool operator called with a non-bool operand of type " + t.getName() + "."
