/**
 * @id cpp/autosar/pointer-or-reference-parameter-to-const
 * @name M7-1-2: A pointer or reference parameter in a function shall be declared as pointer to const or reference to const where possible
 * @description Using a pointer/reference parameter in a function as pointer/reference to const if
 *              the corresponding object is not modified prevents unintended program behaviour.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/m7-1-2
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.FunctionParameter
import codingstandards.cpp.ConstHelpers

from NonConstPointerorReferenceParameter v
where
  not isExcluded(v, ConstPackage::pointerOrReferenceParameterToConstQuery()) and
  isNotDirectlyModified(v) and
  notUsedAsQualifierForNonConst(v) and
  notPassedAsArgToNonConstParam(v) and
  notAssignedToNonLocalNonConst(v) and
  notReturnedFromNonConstFunction(v) and
  not v.getAnAccess().isAddressOfAccessNonConst()
select v,
  "Parameter " + v.getName() +
    " points to an object that is not modified and therefore should be declared as const."
