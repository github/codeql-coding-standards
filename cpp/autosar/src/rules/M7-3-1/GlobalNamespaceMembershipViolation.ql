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

from DeclarationEntry de
where
  not isExcluded(de, ScopePackage::globalNamespaceMembershipViolationQuery()) and
  de.getDeclaration().getNamespace() instanceof GlobalNamespace and
  de.getDeclaration().isTopLevel() and
  not exists(Function f | f = de.getDeclaration() | f.hasGlobalName("main") or f.hasCLinkage())
select de,
  "Declaration " + de.getName() +
    " is in the global namespace and is not a main, a namespace, or an extern \"C\" declaration."
