/**
 * @id cpp/autosar/hierarchies-should-be-based-on-interface-classes
 * @name A10-4-1: Hierarchies should be based on interface classes
 * @description Inheritance hierarchies should be based on interface classes to improve
 *              maintainability.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/a10-4-1
 *       external/autosar/allocated-target/design
 *       external/autosar/audit
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Inheritance

from ClassDerivation cd
where
  not isExcluded(cd, InheritancePackage::hierarchiesShouldBeBasedOnInterfaceClassesQuery()) and
  cd.hasSpecifier("public") and
  not cd.getBaseClass() instanceof AutosarInterfaceClass
select cd, "[AUDIT] Class $@ publicly derives from non-interface class $@.", cd.getDerivedClass(),
  cd.getDerivedClass().getName(), cd.getBaseClass(), cd.getBaseClass().getName()
