/**
 * @id cpp/autosar/public-inheritance-not-used-for-is-a-relationship
 * @name A10-0-1: Public inheritance shall be used to implement 'is-a' relationship
 * @description Public inheritance should differ from non-public inheritance and should be used to
 *              implement an is-a relationship.
 * @kind problem
 * @precision low
 * @problem.severity recommendation
 * @tags external/autosar/id/a10-0-1
 *       external/autosar/allocated-target/design
 *       external/autosar/audit
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from ClassDerivation cd
where
  not isExcluded(cd, InheritancePackage::publicInheritanceNotUsedForIsARelationshipQuery()) and
  cd.hasSpecifier("public")
select cd, "[AUDIT] Confirm is-a relationship in public inheritance of $@ by $@.",
  cd.getBaseClass(), cd.getBaseClass().getName(), cd.getDerivedClass(),
  cd.getDerivedClass().getName()
