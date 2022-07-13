/**
 * @id cpp/cert/throwing-operator-new-returns-null-cert
 * @name MEM55-CPP: Replacement operator new returns null instead of throwing std:bad_alloc
 * @description Replacement implementations of throwing operator new should not return null as it
 *              violates the 'Required behavior' clause from the C++ Standard.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/mem55-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.throwingoperatornewreturnsnull.ThrowingOperatorNewReturnsNull

class ThrowingOperatorNewReturnsNullCertQuery extends ThrowingOperatorNewReturnsNullSharedQuery {
  ThrowingOperatorNewReturnsNullCertQuery() {
    this = AllocationsPackage::throwingOperatorNewReturnsNullCertQuery()
  }
}
