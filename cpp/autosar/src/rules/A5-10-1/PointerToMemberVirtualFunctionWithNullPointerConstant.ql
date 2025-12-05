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
 *       coding-standards/baseline/safety
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.potentiallyvirtualpointeronlycomparestonullptr.PotentiallyVirtualPointerOnlyComparesToNullptr

class PointerToMemberVirtualFunctionWithNullPointerConstantQuery extends PotentiallyVirtualPointerOnlyComparesToNullptrSharedQuery
{
  PointerToMemberVirtualFunctionWithNullPointerConstantQuery() {
    this = PointersPackage::pointerToMemberVirtualFunctionWithNullPointerConstantQuery()
  }
}
