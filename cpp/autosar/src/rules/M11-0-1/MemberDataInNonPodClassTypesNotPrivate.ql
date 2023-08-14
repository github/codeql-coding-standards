/**
 * @id cpp/autosar/member-data-in-non-pod-class-types-not-private
 * @name M11-0-1: Member data in non-POD class types shall be private
 * @description Using member functions to access internal class data allows a class to be maintained
 *              without impacting clients.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m11-0-1
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class NonPODType extends Class {
  NonPODType() { not this.isPod() }
}

from NonPODType p, Field f
where
  not isExcluded(p, ClassesPackage::memberDataInNonPodClassTypesNotPrivateQuery()) and
  f = p.getAField() and
  not f.isCompilerGenerated() and
  (f.isProtected() or f.isPublic())
select f, "Member data in a non-POD class is not private."
