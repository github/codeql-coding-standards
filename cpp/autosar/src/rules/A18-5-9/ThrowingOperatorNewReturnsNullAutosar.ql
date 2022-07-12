/**
 * @id cpp/autosar/throwing-operator-new-returns-null-autosar
 * @name A18-5-9: Replacement operator new returns null instead of throwing std:bad_alloc
 * @description Replacement implementations of throwing operator new should not return null as it
 *              violates the 'Required behavior' clause from the C++ Standard.
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
import codingstandards.cpp.rules.throwingoperatornewreturnsnull.ThrowingOperatorNewReturnsNull

class ThrowingOperatorNewReturnsNullAutosarQuery extends ThrowingOperatorNewReturnsNullSharedQuery {
  ThrowingOperatorNewReturnsNullAutosarQuery() {
    this = AllocationsPackage::throwingOperatorNewReturnsNullAutosarQuery()
  }
}
