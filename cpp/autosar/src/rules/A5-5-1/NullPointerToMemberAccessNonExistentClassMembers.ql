/**
 * @id cpp/autosar/null-pointer-to-member-access-non-existent-class-members
 * @name A5-5-1: Use of pointer to member that is a null pointer
 * @description Accessing the a member through a pointer-to-member expression when the pointer to
 *              member is a null pointer leads to undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a5-5-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.accessofundefinedmemberthroughnullpointer.AccessOfUndefinedMemberThroughNullPointer

class NullPointerToMemberAccessNonExistentClassMembersQuery extends AccessOfUndefinedMemberThroughNullPointerSharedQuery {
  NullPointerToMemberAccessNonExistentClassMembersQuery() {
    this = PointersPackage::nullPointerToMemberAccessNonExistentClassMembersQuery()
  }
}
