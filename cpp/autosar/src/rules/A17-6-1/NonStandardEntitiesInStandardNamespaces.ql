/**
 * @id cpp/autosar/non-standard-entities-in-standard-namespaces
 * @name A17-6-1: Non-standard entities shall not be added to standard namespaces
 * @description Adding declarations or definitions to standard namespaces or their sub-namespaces
 *              leads to undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a17-6-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.nonstandardentitiesinstandardnamespaces.NonStandardEntitiesInStandardNamespaces

class NonStandardEntitiesInStandardNamespacesQuery extends NonStandardEntitiesInStandardNamespacesSharedQuery {
  NonStandardEntitiesInStandardNamespacesQuery() {
    this = ScopePackage::nonStandardEntitiesInStandardNamespacesQuery()
  }
}
