/**
 * @id cpp/autosar/throwing-no-throw-operator-new-delete-autosar
 * @name A18-5-9: Replacement nothrow operator new or operator delete throws an exception
 * @description Replacement implementations of nothrow operator new or operator delete should not
 *              throw exceptions as it violates the 'Required behavior' clause from the C++
 *              Standard.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a18-5-9
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.throwingnothrowoperatornewdelete.ThrowingNoThrowOperatorNewDelete

class ThrowingNoThrowOperatorNewDeleteAutosarQuery extends ThrowingNoThrowOperatorNewDeleteSharedQuery {
  ThrowingNoThrowOperatorNewDeleteAutosarQuery() {
    this = AllocationsPackage::throwingNoThrowOperatorNewDeleteAutosarQuery()
  }
}
