/**
 * @id cpp/misra/forwarding-references-and-forward-not-used-together
 * @name RULE-28-6-2: Forwarding references and std::forward shall be used together
 * @description Forwarding references and std::forward shall be used together.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-28-6-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.forwardingreferencesandforwardnotusedtogether.ForwardingReferencesAndForwardNotUsedTogether

class ForwardingReferencesAndForwardNotUsedTogetherQuery extends ForwardingReferencesAndForwardNotUsedTogetherSharedQuery
{
  ForwardingReferencesAndForwardNotUsedTogetherQuery() {
    this = ImportMisra23Package::forwardingReferencesAndForwardNotUsedTogetherQuery()
  }
}
