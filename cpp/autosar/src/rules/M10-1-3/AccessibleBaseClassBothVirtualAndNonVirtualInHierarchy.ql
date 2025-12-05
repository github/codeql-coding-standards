/**
 * @id cpp/autosar/accessible-base-class-both-virtual-and-non-virtual-in-hierarchy
 * @name M10-1-3: An accessible base class shall not be both virtual and non-virtual in the same hierarchy
 * @description A base class must not be virtual and non-virtual in the same hierarchy to avoid
 *              copies of the object and confusing behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m10-1-3
 *       coding-standards/baseline/safety
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.virtualandnonvirtualclassinthehierarchy.VirtualAndNonVirtualClassInTheHierarchy

class AccessibleBaseClassBothVirtualAndNonVirtualInHierarchyQuery extends VirtualAndNonVirtualClassInTheHierarchySharedQuery
{
  AccessibleBaseClassBothVirtualAndNonVirtualInHierarchyQuery() {
    this = InheritancePackage::accessibleBaseClassBothVirtualAndNonVirtualInHierarchyQuery()
  }
}
