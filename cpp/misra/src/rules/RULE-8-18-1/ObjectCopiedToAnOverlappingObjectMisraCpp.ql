/**
 * @id cpp/misra/object-copied-to-an-overlapping-object-misra-cpp
 * @name RULE-8-18-1: An slice of an array must not be copied to an overlapping region of itself
 * @description Copying a slice of an array to an overlapping region of the same array causes
 *              undefined behavior.
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
import codingstandards.cpp.rules.objectcopiedtoanoverlappingobject.ObjectCopiedToAnOverlappingObject

class ObjectCopiedToAnOverlappingObjectMisraCppQuery extends ObjectCopiedToAnOverlappingObjectSharedQuery {
  ObjectCopiedToAnOverlappingObjectMisraCppQuery() {
    this = Memory4Package::objectCopiedToAnOverlappingObjectMisraCppQuery()
  }
}
