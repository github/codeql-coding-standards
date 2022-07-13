/**
 * @id cpp/autosar/uninitialized-static-pointer-to-member-use
 * @name A5-5-1: Use of a null pointer-to-member value in a pointer-to-member expression
 * @description The use of a null pointer-to-member value as the second operand in a
 *              pointer-to-member expression results in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a5-5-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.accessofundefinedmemberthroughuninitializedstaticpointer.AccessOfUndefinedMemberThroughUninitializedStaticPointer

class UninitializedStaticPointerToMemberUseQuery extends AccessOfUndefinedMemberThroughUninitializedStaticPointerSharedQuery {
  UninitializedStaticPointerToMemberUseQuery() {
    this = PointersPackage::uninitializedStaticPointerToMemberUseQuery()
  }
}
