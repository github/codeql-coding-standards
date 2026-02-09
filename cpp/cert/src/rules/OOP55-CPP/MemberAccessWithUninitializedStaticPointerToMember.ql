/**
 * @id cpp/cert/member-access-with-uninitialized-static-pointer-to-member
 * @name OOP55-CPP: Use of a null pointer-to-member value in a pointer-to-member expression
 * @description The use of a null pointer-to-member value as the second operand in a
 *              pointer-to-member expression results in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/oop55-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.accessofundefinedmemberthroughuninitializedstaticpointer.AccessOfUndefinedMemberThroughUninitializedStaticPointer

class MemberAccessWithUninitializedStaticPointerToMemberQuery extends AccessOfUndefinedMemberThroughUninitializedStaticPointerSharedQuery
{
  MemberAccessWithUninitializedStaticPointerToMemberQuery() {
    this = PointersPackage::memberAccessWithUninitializedStaticPointerToMemberQuery()
  }
}
