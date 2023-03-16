/**
 * @id cpp/autosar/object-assigned-to-an-overlapping-object
 * @name M0-2-1: An object shall not be assigned to an overlapping object
 * @description An object shall not be assigned to an overlapping object.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/m0-2-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.overlappingobjectassignment.OverlappingObjectAssignment

class ObjectAssignedToAnOverlappingObjectQuery extends OverlappingObjectAssignmentSharedQuery {
  ObjectAssignedToAnOverlappingObjectQuery() {
    this = RepresentationPackage::objectAssignedToAnOverlappingObjectQuery()
  }
}
