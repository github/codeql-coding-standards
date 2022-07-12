/**
 * @id cpp/autosar/classes-should-not-be-derived-from-virtual-bases
 * @name M10-1-1: Classes should not be derived from virtual bases
 * @description Classes should not be derived from virtual bases to avoid potentially undefined or
 *              complicated code.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m10-1-1
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

from VirtualClassDerivation vcd
where not isExcluded(vcd, InheritancePackage::classesShouldNotBeDerivedFromVirtualBasesQuery())
select vcd, "Class should not derive virtually from base class $@.", vcd.getBaseClass(),
  vcd.getBaseClass().getName()
