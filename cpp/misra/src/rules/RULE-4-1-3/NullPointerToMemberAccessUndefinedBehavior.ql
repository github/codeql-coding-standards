/**
 * @id cpp/misra/null-pointer-to-member-access-undefined-behavior
 * @name RULE-4-1-3: Null pointer-to-member access leads to undefined behavior
 * @description Using a null pointer-to-member value as the second operand in a pointer-to-member
 *              expression results in undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-4-1-3
 *       correctness
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.accessofundefinedmemberthroughnullpointer.AccessOfUndefinedMemberThroughNullPointer

class NullPointerToMemberAccessUndefinedBehaviorQuery extends AccessOfUndefinedMemberThroughNullPointerSharedQuery
{
  NullPointerToMemberAccessUndefinedBehaviorQuery() {
    this = UndefinedPackage::nullPointerToMemberAccessUndefinedBehaviorQuery()
  }
}
