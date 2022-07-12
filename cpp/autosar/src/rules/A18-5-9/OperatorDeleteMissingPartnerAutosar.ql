/**
 * @id cpp/autosar/operator-delete-missing-partner-autosar
 * @name A18-5-9: Replacement operator delete missing partner
 * @description Replacement implementations of operator delete should override the variants both
 *              with and without std::size_t, otherwise it violates the 'Required behavior' clause
 *              from the C++ Standard.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a18-5-9
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.operatordeletemissingpartner.OperatorDeleteMissingPartner

class OperatorDeleteMissingPartnerAutosarQuery extends OperatorDeleteMissingPartnerSharedQuery {
  OperatorDeleteMissingPartnerAutosarQuery() {
    this = AllocationsPackage::operatorDeleteMissingPartnerAutosarQuery()
  }
}
