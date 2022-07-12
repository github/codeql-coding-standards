/**
 * @id cpp/autosar/base-class-can-be-virtual-only-in-diamond-hierarchy
 * @name M10-1-2: A base class shall only be declared virtual if it is used in a diamond hierarchy
 * @description Virtual base classes shall only be used if they are later used as a common base
 *              class in a diamond hierarchy.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m10-1-2
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

predicate isVirtualClassDerivationInHierarchy(Class derived, VirtualClassDerivation vcd) {
  derived.getABaseClass*().getADerivation() = vcd
}

class DiamondHierarchyVirtualClassDerivation extends VirtualClassDerivation {
  DiamondHierarchyVirtualClassDerivation() {
    // holds if a class that is the bottom of a diamond hierarchy exists with this derivation in its hierarchy
    exists(Class bottom |
      // where the class has multiple derivations
      count(bottom.getADerivation()) > 1 and
      // and "this" virtual class derivation is in the hierarchy of the class
      isVirtualClassDerivationInHierarchy(bottom, this) and
      // and a virtual class derivation in a different class with a shared base class exists
      isVirtualClassDerivationInHierarchy(bottom,
        any(VirtualClassDerivation vcd |
          vcd != this and
          vcd.getBaseClass() = this.getBaseClass()
        ))
    )
  }
}

from VirtualClassDerivation vcd
where
  not isExcluded(vcd, InheritancePackage::baseClassCanBeVirtualOnlyInDiamondHierarchyQuery()) and
  not vcd instanceof DiamondHierarchyVirtualClassDerivation
select vcd, "Base class $@ derived virtually by $@ but is not used in a diamond hierarchy.",
  vcd.getBaseClass(), vcd.getBaseClass().getName(), vcd.getDerivedClass(),
  vcd.getDerivedClass().getName()
