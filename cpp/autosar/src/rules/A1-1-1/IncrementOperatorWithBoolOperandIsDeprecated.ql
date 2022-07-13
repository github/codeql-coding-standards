/**
 * @id cpp/autosar/increment-operator-with-bool-operand-is-deprecated
 * @name A1-1-1: The use of the `++` increment operator with an operand of type `bool` is deprecated
 * @description The use of the `++` increment operator with an operand of type `bool` is deprecated.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a1-1-1
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from IncrementOperation io
where
  not isExcluded(io, ToolchainPackage::incrementOperatorWithBoolOperandIsDeprecatedQuery()) and
  (
    io.getAnOperand().getUnspecifiedType() instanceof BoolType
    or
    io.getAnOperand().getUnspecifiedType().(ReferenceType).getBaseType().getUnspecifiedType()
      instanceof BoolType
  )
select io, "Incrementing `bool` lvalue is deprecated."
