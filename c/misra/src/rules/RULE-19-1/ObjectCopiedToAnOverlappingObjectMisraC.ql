/**
 * @id c/misra/object-copied-to-an-overlapping-object-misra-c
 * @name RULE-19-1: An object shall not be copied to an overlapping object
 * @description An object shall not be copied to an overlapping object.
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
import codingstandards.cpp.rules.objectcopiedtoanoverlappingobject.ObjectCopiedToAnOverlappingObject

class ObjectCopiedToAnOverlappingObjectMisraCQuery extends ObjectCopiedToAnOverlappingObjectSharedQuery {
  ObjectCopiedToAnOverlappingObjectMisraCQuery() {
    this = Contracts7Package::objectCopiedToAnOverlappingObjectMisraCQuery()
  }
}
