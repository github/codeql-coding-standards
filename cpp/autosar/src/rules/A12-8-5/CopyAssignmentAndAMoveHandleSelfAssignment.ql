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
import codingstandards.cpp.Operator

predicate isUserCopyOrUserMove(Operator o) {
  o instanceof UserCopyOperator or
  o instanceof UserMoveOperator
}

predicate callsStdSwap(Function f) {
  exists(FunctionCall fc |
    fc.getTarget().hasGlobalOrStdName("swap") and
    fc.getEnclosingFunction() = f
  )
}

predicate callsNoExceptSwap(Operator o) {
  exists(Function f, FunctionCall fc |
    callsStdSwap(f) and
    fc.getEnclosingFunction() = o and
    fc.getTarget() = f
  )
}

predicate checksForSelfAssignment(Operator o) {
  exists(IfStmt i, ComparisonOperation c |
    i.getEnclosingFunction() = o and
    i.getCondition() = c and
    (
      c.getLeftOperand().toString() = "this" or
      c.getRightOperand().toString() = "this"
    )
  )
}

from Operator o
where
  not isExcluded(o, OperatorInvariantsPackage::copyAssignmentAndAMoveHandleSelfAssignmentQuery()) and
  isUserCopyOrUserMove(o) and
  not callsNoExceptSwap(o) and
  not checksForSelfAssignment(o)
select o, "User defined copy or user defined move does not handle self-assignment correctly."
