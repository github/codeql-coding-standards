/**
 * @id cpp/autosar/pointer-to-member-access-non-existent-class-members
 * @name A5-5-1: A pointer to member shall not access non-existent class members
 * @description A pointer to member shall not access non-existent class members because this leads
 *              to undefined behavior.
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
import codingstandards.cpp.rules.accessofnonexistingmemberthroughpointertomember.AccessOfNonExistingMemberThroughPointerToMember

class PointerToMemberAccessNonExistentClassMembersQuery extends AccessOfNonExistingMemberThroughPointerToMemberSharedQuery {
  PointerToMemberAccessNonExistentClassMembersQuery() {
    this = PointersPackage::pointerToMemberAccessNonExistentClassMembersQuery()
  }
}
