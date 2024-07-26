/**
 * Provides a library with a `problems` predicate for the following issue:
 * User-provided copy assignment operators and move assignment operators shall handle
 * self-assignment.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Operator

abstract class CopyAndMoveAssignmentsShallHandleSelfAssignmentSharedQuery extends Query { }

Query getQuery() { result instanceof CopyAndMoveAssignmentsShallHandleSelfAssignmentSharedQuery }

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

query predicate problems(Operator o, string message) {
  not isExcluded(o, getQuery()) and
  isUserCopyOrUserMove(o) and
  not callsNoExceptSwap(o) and
  not checksForSelfAssignment(o) and
  message = "User defined copy or user defined move does not handle self-assignment correctly."
}
