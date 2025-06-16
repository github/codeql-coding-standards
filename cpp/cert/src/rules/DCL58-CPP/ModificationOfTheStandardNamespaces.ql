/**
 * @id cpp/cert/modification-of-the-standard-namespaces
 * @name DCL58-CPP: Do not modify the standard namespaces
 * @description Adding declarations or definitions to the standard namespaces leads to undefined
 *              behavior and is only allowed under special circumstances described in the C++
 *              Standard.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/dcl58-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.nonstandardentitiesinstandardnamespaces.NonStandardEntitiesInStandardNamespaces

class ModificationOfTheStandardNamespacesQuery extends NonStandardEntitiesInStandardNamespacesSharedQuery
{
  ModificationOfTheStandardNamespacesQuery() {
    this = ScopePackage::modificationOfTheStandardNamespacesQuery()
  }
}
