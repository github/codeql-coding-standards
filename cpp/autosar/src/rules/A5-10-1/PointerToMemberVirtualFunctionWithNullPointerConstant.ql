/**
 * @id cpp/autosar/pointer-to-member-virtual-function-with-null-pointer-constant
 * @name A5-10-1: A pointer to member virtual function shall only be tested for equality with null-pointer-constant
 * @description A pointer to member virtual function shall only be tested for equality with
 *              null-pointer-constant, because an equality comparison with anything other than a
 *              null-pointer-constant is unspecified.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a5-10-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from
  EqualityOperation equalityComparison, MemberFunction virtualFunction,
  FunctionAccess accessOperand, Expr otherOperand
where
  not isExcluded(equalityComparison,
    PointersPackage::pointerToMemberVirtualFunctionWithNullPointerConstantQuery()) and
  virtualFunction.isVirtual() and
  equalityComparison.getAnOperand() = accessOperand and
  accessOperand.getTarget() = virtualFunction and
  otherOperand = equalityComparison.getAnOperand() and
  not otherOperand = accessOperand and
  not otherOperand.getType() instanceof NullPointerType
select equalityComparison,
  "A pointer to member virtual function $@ is tested for equality with non-null-pointer-constant $@. ",
  virtualFunction, virtualFunction.getName(), otherOperand, otherOperand.toString()
