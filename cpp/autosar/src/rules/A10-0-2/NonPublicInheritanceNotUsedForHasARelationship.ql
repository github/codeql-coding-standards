/**
 * @id cpp/autosar/non-public-inheritance-not-used-for-has-a-relationship
 * @name A10-0-2: Membership or non-public inheritance shall be used to implement 'has-a' relationship
 * @description Non-public inheritance should differ from public inheritance and should be used to
 *              implement a has-a relationship.
 * @kind problem
 * @precision low
 * @problem.severity recommendation
 * @tags external/autosar/id/a10-0-2
 *       external/autosar/allocated-target/design
 *       external/autosar/audit
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from ClassDerivation cd
where
  not isExcluded(cd, InheritancePackage::nonPublicInheritanceNotUsedForHasARelationshipQuery()) and
  not cd.hasSpecifier("public")
select cd, "[AUDIT] Confirm has-a relationship in non-public inheritance of $@ by $@.",
  cd.getBaseClass(), cd.getBaseClass().getName(), cd.getDerivedClass(),
  cd.getDerivedClass().getName()
