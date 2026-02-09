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
  // Ignore cases where the type is unknown - this will typically be in unevaluated contexts
  // within uninstantiated templates. It's necessary to check for this explicitly because
  // not all unevaluated contexts are considered to be `isFromUninstantiatedTemplate(_)`,
  // e.g. `noexcept` specifiers
  not t instanceof UnknownType and
  not exists(ReferenceType rt |
    rt = t.getUnderlyingType().getUnspecifiedType() and rt.getBaseType() instanceof BoolType
  ) and
  not operand.isFromUninstantiatedTemplate(_)
select operand, "Call to bool operator with a non-bool operand of type '" + t.getName() + "'."
