/**
 * @id cpp/autosar/user-defined-assignment-operator-virtual
 * @name A10-3-5: A user-defined assignment operator shall not be virtual
 * @description A user-defined assignment operator overrider can receive a reference to an unrelated
 *              class sharing a base class which can result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a10-3-5
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Operator

from UserAssignmentOperator op
where
  not isExcluded(op, OperatorsPackage::userDefinedAssignmentOperatorVirtualQuery()) and
  op.isVirtual()
select op, "User-defined assignment operator is declared as virtual."
