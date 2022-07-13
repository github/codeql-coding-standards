/**
 * @id cpp/autosar/throwing-operator-new-throws-invalid-exception-autosar
 * @name A18-5-9: Replacement operator new throws an exception other than std::bad_alloc
 * @description Replacement implementations of throwing operator new should not throw exceptions
 *              other than std::bad_alloc as it violates the 'Required behavior' clause from the C++
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
import codingstandards.cpp.rules.throwingoperatornewthrowsinvalidexception.ThrowingOperatorNewThrowsInvalidException

class ThrowingOperatorNewThrowsInvalidExceptionAutosarQuery extends ThrowingOperatorNewThrowsInvalidExceptionSharedQuery {
  ThrowingOperatorNewThrowsInvalidExceptionAutosarQuery() {
    this = AllocationsPackage::throwingOperatorNewThrowsInvalidExceptionAutosarQuery()
  }
}
