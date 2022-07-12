/**
 * @id cpp/autosar/accessible-base-class-both-virtual-and-non-virtual-in-hierarchy
 * @name M10-1-3: An accessible base class shall not be both virtual and non-virtual in the same hierarchy
 * @description A base class must not be virtual and non-virtual in the same hierarchy to avoid
 *              copies of the object and confusing behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m10-1-3
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Class c1, Class c2, Class c3, Class base, ClassDerivation cd1, ClassDerivation cd2
where
  not isExcluded(c3,
    InheritancePackage::accessibleBaseClassBothVirtualAndNonVirtualInHierarchyQuery()) and
  // for each pair of classes, get all of their derivations
  cd1 = c1.getADerivation() and
  cd2 = c2.getADerivation() and
  // where they share the same base class
  base = cd1.getBaseClass() and
  base = cd2.getBaseClass() and
  // but one is virtual, and one is not, and the derivations are in different classes
  cd1.isVirtual() and
  not cd2.isVirtual() and
  // and there is some 'other class' that derives from both of these classes
  c3.derivesFrom*(c1) and
  c3.derivesFrom*(c2) and
  // and the base class is accessible from the 'other class'
  c3.getAMemberFunction().getEnclosingAccessHolder().canAccessClass(base, c3)
select c3, "Class inherits base class $@, which is derived virtual by $@ and non-virtual by $@.",
  base, base.getName(), cd1, cd1.getDerivedClass().toString(), c2, cd2.getDerivedClass().toString()
