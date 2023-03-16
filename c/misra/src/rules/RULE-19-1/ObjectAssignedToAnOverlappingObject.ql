/**
 * @id c/misra/object-assigned-to-an-overlapping-object
 * @name RULE-19-1: An object shall not be assigned to an overlapping object
 * @description An object shall not be assigned to an overlapping object.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-19-1
 *       correctness
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.overlappingobjectassignment.OverlappingObjectAssignment

class ObjectAssignedToAnOverlappingObjectQuery extends OverlappingObjectAssignmentSharedQuery {
  ObjectAssignedToAnOverlappingObjectQuery() {
    this = Contracts7Package::objectAssignedToAnOverlappingObjectQuery()
  }
}
