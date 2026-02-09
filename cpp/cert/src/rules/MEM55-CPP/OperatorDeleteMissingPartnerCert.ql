/**
 * @id cpp/cert/operator-delete-missing-partner-cert
 * @name MEM55-CPP: Replacement operator delete missing partner
 * @description Replacement implementations of operator delete should override the variants both
 *              with and without std::size_t, otherwise it violates the 'Required behavior' clause
 *              from the C++ Standard.
 * @kind problem
 * @precision very-high
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
import codingstandards.cpp.rules.operatordeletemissingpartner.OperatorDeleteMissingPartner

class OperatorDeleteMissingPartnerCertQuery extends OperatorDeleteMissingPartnerSharedQuery {
  OperatorDeleteMissingPartnerCertQuery() {
    this = AllocationsPackage::operatorDeleteMissingPartnerCertQuery()
  }
}
