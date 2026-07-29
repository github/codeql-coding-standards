/**
 * @id cpp/misra/non-existent-member-access-undefined-behavior
 * @name RULE-4-1-3: Pointer-to-member access of nonexistent member leads to undefined behavior
 * @description Using a pointer-to-member expression where the dynamic type of the first operand
 *              does not contain the member pointed to by the second operand results in undefined
 *              behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-4-1-3
 *       correctness
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.accessofnonexistingmemberthroughpointertomember.AccessOfNonExistingMemberThroughPointerToMember

class NonExistentMemberAccessUndefinedBehaviorQuery extends AccessOfNonExistingMemberThroughPointerToMemberSharedQuery
{
  NonExistentMemberAccessUndefinedBehaviorQuery() {
    this = UndefinedPackage::nonExistentMemberAccessUndefinedBehaviorQuery()
  }
}
