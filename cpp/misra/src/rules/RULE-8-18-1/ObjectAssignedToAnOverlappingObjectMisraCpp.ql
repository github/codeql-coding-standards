/**
 * @id cpp/misra/object-assigned-to-an-overlapping-object-misra-cpp
 * @name RULE-8-18-1: A member of a union must not be copied to its another member
 * @description Copying a member of a union to another causes undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-8-18-1
 *       scope/system
 *       correctness
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.objectassignedtoanoverlappingobject.ObjectAssignedToAnOverlappingObject

class ObjectAssignedToAnOverlappingObjectMisraCppQuery extends ObjectAssignedToAnOverlappingObjectSharedQuery {
  ObjectAssignedToAnOverlappingObjectMisraCppQuery() {
    this = Memory4Package::objectAssignedToAnOverlappingObjectMisraCppQuery()
  }
}
