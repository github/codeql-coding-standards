/**
 * @id cpp/autosar/copy-assignment-and-a-move-handle-self-assignment
 * @name A12-8-5: A copy assignment and a move assignment operators shall handle self-assignment
 * @description User-defined copy and move assignment operators must prevent self-assignment so that
 *              the operation will not leave the object in an intermediate state, since destroying
 *              object-local resources will invalidate them and violate copy and move
 *              post-conditions.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a12-8-5
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.copyandmoveassignmentsshallhandleselfassignment.CopyAndMoveAssignmentsShallHandleSelfAssignment

class CopyAssignmentAndAMoveHandleSelfAssignmentQuery extends CopyAndMoveAssignmentsShallHandleSelfAssignmentSharedQuery
{
  CopyAssignmentAndAMoveHandleSelfAssignmentQuery() {
    this = OperatorInvariantsPackage::copyAssignmentAndAMoveHandleSelfAssignmentQuery()
  }
}
