/**
 * @id cpp/autosar/bitwise-operator-applied-to-signed-types
 * @name M5-0-21: Bitwise operators shall only be applied to operands of unsigned underlying type
 * @description Bitwise operations (~, <<, <<=, >>, >>=, &, &=, ^, ^=, | and |=) are not normally
 *              meaningful on signed integers or enumeration constants. Additionally, an
 *              implementation-defined result is obtained if a right shift is applied to a negative
 *              value.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-0-21
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Operation o, VariableAccess va
where
  not isExcluded(o, ExpressionsPackage::bitwiseOperatorAppliedToSignedTypesQuery()) and
  (
    o instanceof UnaryBitwiseOperation or
    o instanceof BinaryBitwiseOperation or
    o instanceof AssignBitwiseOperation
  ) and
  o.getAnOperand() = va and
  va.getTarget().getUnderlyingType().(IntegralType).isSigned()
select o, "Signed integral $@ used as an operand to bitwise operation '" + o.getOperator() + "'.",
  va, "expression"
