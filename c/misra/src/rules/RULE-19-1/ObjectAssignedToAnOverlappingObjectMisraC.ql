/**
 * @id c/misra/object-assigned-to-an-overlapping-object-misra-c
 * @name RULE-19-1: An object shall not be assigned to an overlapping object
 * @description An object shall not be copied or assigned to an overlapping object.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-19-1
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.objectassignedtoanoverlappingobject.ObjectAssignedToAnOverlappingObject

class ObjectAssignedToAnOverlappingObjectMisraCQuery extends ObjectAssignedToAnOverlappingObjectSharedQuery {
  ObjectAssignedToAnOverlappingObjectMisraCQuery() {
    this = Contracts7Package::objectAssignedToAnOverlappingObjectMisraCQuery()
  }
}
