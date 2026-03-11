/**
 * @id cpp/misra/automatic-storage-assigned-to-object-greater-lifetime
 * @name RULE-6-8-3: Declare objects with appropriate storage durations
 * @description When storage durations are not compatible between assigned pointers it can lead to
 *              referring to objects outside of their lifetime, which is undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-8-3
 *       correctness
 *       security
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.donotcopyaddressofautostorageobjecttootherobject.DoNotCopyAddressOfAutoStorageObjectToOtherObject

class AutomaticStorageAssignedToObjectGreaterLifetimeConfig extends DoNotCopyAddressOfAutoStorageObjectToOtherObjectSharedQuery
{
  AutomaticStorageAssignedToObjectGreaterLifetimeConfig() {
    this = LifetimePackage::automaticStorageAssignedToObjectGreaterLifetimeQuery()
  }
}
