/**
 * @id cpp/autosar/downcasting-should-not-be-performed-on-polymorphic-types
 * @name M5-2-3: Casts from a base class to a derived class should not be performed on polymorphic types
 * @description A polymorphic object should not be cast to a derived type, so as to maintain
 *              abstraction and avoid coupling.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m5-2-3
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

from Cast cast, Class base, Class derived
where
  not isExcluded(cast, InheritancePackage::downcastingShouldNotBePerformedOnPolymorphicTypesQuery()) and
  not cast.isFromTemplateInstantiation(_) and
  not cast.isImplicit() and
  derived.isPolymorphic() and
  derived.getABaseClass+() = base and
  cast.getType().stripType() = derived and
  cast.getExpr().getType().stripType() = base
select cast, "Downcast of polymorphic object of type $@ to $@.", base, base.getName(), derived,
  derived.getName()
