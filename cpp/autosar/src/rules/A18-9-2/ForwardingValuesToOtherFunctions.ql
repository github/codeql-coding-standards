/**
 * @id cpp/autosar/forwarding-values-to-other-functions
 * @name A18-9-2: Rvalue references are forwarded with std::move and forwarding reference with std::forward
 * @description Rvalue references are forwarded with std::move and forwarding reference with
 *              std::forward.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a18-9-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.forwardingreferencesandforwardnotusedtogether.ForwardingReferencesAndForwardNotUsedTogether

class ForwardingValuesToOtherFunctionsQuery extends ForwardingReferencesAndForwardNotUsedTogetherSharedQuery
{
  ForwardingValuesToOtherFunctionsQuery() {
    this = MoveForwardPackage::forwardingValuesToOtherFunctionsQuery()
  }
}
