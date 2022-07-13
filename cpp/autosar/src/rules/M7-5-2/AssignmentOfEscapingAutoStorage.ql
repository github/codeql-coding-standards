/**
 * @id cpp/autosar/assignment-of-escaping-auto-storage
 * @name M7-5-2: Do not assign the address of an object with automatic storage to an object that may persist after it's lifetime
 * @description The address of an object with automatic storage shall not be assigned to another
 *              object that may persist after the first object has ceased to exist.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m7-5-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.donotcopyaddressofautostorageobjecttootherobject.DoNotCopyAddressOfAutoStorageObjectToOtherObject

class AssignmentOfEscapingAutoStorageQuery extends DoNotCopyAddressOfAutoStorageObjectToOtherObjectSharedQuery {
  AssignmentOfEscapingAutoStorageQuery() {
    this = FreedPackage::assignmentOfEscapingAutoStorageQuery()
  }
}
