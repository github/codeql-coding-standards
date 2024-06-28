/**
 * @id cpp/autosar/global-namespace-membership-violation
 * @name M7-3-1: The global namespace shall only contain main, namespace declarations and extern "C" declarations
 * @description Declarations in the global namespace become part of the names found during lookup
 *              and reducing the set of found names ensures that they meet a developer's
 *              expectations.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m7-3-1
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.globalnamespacedeclarations_shared.GlobalNamespaceDeclarations_shared

class GlobalNamespaceMembershipViolationQuery extends GlobalNamespaceDeclarations_sharedSharedQuery {
  GlobalNamespaceMembershipViolationQuery() {
    this = ScopePackage::globalNamespaceMembershipViolationQuery()
  }
}
