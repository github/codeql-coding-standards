/**
 * @id cpp/cert/use-of-pointer-to-member-to-access-nonexistent-member
 * @name OOP55-CPP: Do not use pointer-to-member operators to access nonexistent members
 * @description The use of a pointer-to-member expression where the dynamic type of the first
 *              operand does not contain the member pointed to by the second operand results in
 *              undefined behavior.
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
import codingstandards.cpp.rules.accessofnonexistingmemberthroughpointertomember.AccessOfNonExistingMemberThroughPointerToMember

class UseOfPointerToMemberToAccessNonexistentMemberQuery extends AccessOfNonExistingMemberThroughPointerToMemberSharedQuery
{
  UseOfPointerToMemberToAccessNonexistentMemberQuery() {
    this = PointersPackage::useOfPointerToMemberToAccessNonexistentMemberQuery()
  }
}
