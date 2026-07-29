/**
 * @id cpp/misra/uninitialized-static-pointer-to-member-undefined-behavior
 * @name RULE-4-1-3: Uninitialized static pointer-to-member access leads to undefined behavior
 * @description Using an uninitialized static pointer-to-member in a pointer-to-member expression
 *              results in undefined behavior.
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
import codingstandards.cpp.rules.accessofundefinedmemberthroughuninitializedstaticpointer.AccessOfUndefinedMemberThroughUninitializedStaticPointer

class UninitializedStaticPointerToMemberUndefinedBehaviorQuery extends AccessOfUndefinedMemberThroughUninitializedStaticPointerSharedQuery
{
  UninitializedStaticPointerToMemberUndefinedBehaviorQuery() {
    this = UndefinedPackage::uninitializedStaticPointerToMemberUndefinedBehaviorQuery()
  }
}
