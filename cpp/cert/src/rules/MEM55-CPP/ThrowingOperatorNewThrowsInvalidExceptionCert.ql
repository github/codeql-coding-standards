/**
 * @id cpp/cert/throwing-operator-new-throws-invalid-exception-cert
 * @name MEM55-CPP: Replacement operator new throws an exception other than std::bad_alloc
 * @description Replacement implementations of throwing operator new should not throw exceptions
 *              other than std::bad_alloc as it violates the 'Required behavior' clause from the C++
 *              Standard.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/mem55-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.throwingoperatornewthrowsinvalidexception.ThrowingOperatorNewThrowsInvalidException

class ThrowingOperatorNewThrowsInvalidExceptionCertQuery extends ThrowingOperatorNewThrowsInvalidExceptionSharedQuery
{
  ThrowingOperatorNewThrowsInvalidExceptionCertQuery() {
    this = AllocationsPackage::throwingOperatorNewThrowsInvalidExceptionCertQuery()
  }
}
