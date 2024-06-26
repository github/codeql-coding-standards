/**
 * @id cpp/misra/virtual-and-non-virtual-class-in-the-hierarchy
 * @name RULE-13-1-2: An accessible base class shall not be both virtual and non-virtual in the same hierarchy
 * @description An accessible base class shall not be both virtual and non-virtual in the same
 *              hierarchy.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-13-1-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.virtualandnonvirtualclassinthehierarchy_shared.VirtualAndNonVirtualClassInTheHierarchy_shared

class VirtualAndNonVirtualClassInTheHierarchyQuery extends VirtualAndNonVirtualClassInTheHierarchy_sharedSharedQuery
{
  VirtualAndNonVirtualClassInTheHierarchyQuery() {
    this = ImportMisra23Package::virtualAndNonVirtualClassInTheHierarchyQuery()
  }
}
