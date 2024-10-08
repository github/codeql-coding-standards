/**
 * @id cpp/autosar/bitwise-operator-operands-have-different-underlying-type
 * @name M5-0-20: Non-constant operands to a binary bitwise operator shall have the same underlying type
 * @description Using operands of the same underlying type documents that it is the number of bits
 *              in the final (promoted and balanced) type that are used, and not the number of bits
 *              in the original types of the expression.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-0-20
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Conversion

predicate isBinaryBitwiseOperation(Operation o, VariableAccess l, VariableAccess r) {
  exists(BinaryBitwiseOperation bbo | bbo = o |
    l = bbo.getLeftOperand() and r = bbo.getRightOperand()
  )
  or
  exists(AssignBitwiseOperation abo | abo = o |
    l = abo.getLValue() and
    r = abo.getRValue()
  )
}

from
  Operation o, VariableAccess left, VariableAccess right, Type leftUnderlyingType,
  Type rightUnderlyingType
where
  not isExcluded(o, ExpressionsPackage::bitwiseOperatorOperandsHaveDifferentUnderlyingTypeQuery()) and
  not o.isFromUninstantiatedTemplate(_) and
  isBinaryBitwiseOperation(o, left, right) and
  leftUnderlyingType = MisraConversion::getUnderlyingType(left) and
  rightUnderlyingType = MisraConversion::getUnderlyingType(right) and
  leftUnderlyingType != rightUnderlyingType
select o,
  "Operands of the '" + o.getOperator() + "' operation have different underlying types '" +
    leftUnderlyingType.getName() + "' and '" + rightUnderlyingType.getName() + "'."
