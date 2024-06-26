/**
 * @id cpp/misra/copy-and-move-assignments-shall-handle-self-assignment
 * @name DIR-15-8-1: User-provided copy assignment operators and move assignment operators shall handle self-assignment
 * @description User-provided copy assignment operators and move assignment operators shall handle
 *              self-assignment.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/dir-15-8-1
 *       external/misra/allocated-target/implementation
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.copyandmoveassignmentsshallhandleselfassignment_shared.CopyAndMoveAssignmentsShallHandleSelfAssignment_shared

class CopyAndMoveAssignmentsShallHandleSelfAssignmentQuery extends CopyAndMoveAssignmentsShallHandleSelfAssignment_sharedSharedQuery {
  CopyAndMoveAssignmentsShallHandleSelfAssignmentQuery() {
    this = ImportMisra23Package::copyAndMoveAssignmentsShallHandleSelfAssignmentQuery()
  }
}
