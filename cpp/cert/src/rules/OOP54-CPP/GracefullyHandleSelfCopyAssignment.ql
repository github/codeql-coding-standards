/**
 * @id cpp/cert/gracefully-handle-self-copy-assignment
 * @name OOP54-CPP: Gracefully handle self-copy assignment
 * @description Gracefully handle self-copy assignment so that the operation will not leave the
 *              object in an intermediate state, since destroying object-local resources will
 *              invalidate them and violate copy and move post-conditions.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/oop54-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Operator

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

from UserCopyOrUserMoveOperator o
where
  not isExcluded(o, OperatorInvariantsPackage::gracefullyHandleSelfCopyAssignmentQuery()) and
  not callsNoExceptSwap(o) and
  not checksForSelfAssignment(o)
select o, "User defined copy or user defined move does not handle self-assignment correctly. "
