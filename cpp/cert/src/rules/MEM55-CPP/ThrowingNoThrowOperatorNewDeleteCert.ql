/**
 * @id cpp/cert/throwing-no-throw-operator-new-delete-cert
 * @name MEM55-CPP: Replacement nothrow operator new or operator delete throws an exception
 * @description Replacement implementations of nothrow operator new or operator delete should not
 *              throw exceptions as it violates the 'Required behavior' clause from the C++
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
import codingstandards.cpp.rules.throwingnothrowoperatornewdelete.ThrowingNoThrowOperatorNewDelete

class ThrowingNoThrowOperatorNewDeleteCertQuery extends ThrowingNoThrowOperatorNewDeleteSharedQuery {
  ThrowingNoThrowOperatorNewDeleteCertQuery() {
    this = AllocationsPackage::throwingNoThrowOperatorNewDeleteCertQuery()
  }
}
