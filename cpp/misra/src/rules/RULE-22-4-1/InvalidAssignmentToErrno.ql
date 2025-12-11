/**
 * @id cpp/misra/invalid-assignment-to-errno
 * @name RULE-22-4-1: The literal value zero shall be the only value assigned to errno
 * @description C++ provides better options for error handling than the use of errno. Errno should
 *              not be used for reporting errors within project code.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-4-1
 *       scope/single-translation-unit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.standardlibrary.Errno
import codingstandards.cpp.Literals

from Assignment assign, VariableAccess errno, Expr rvalue, string message
where
  not isExcluded(assign, Preconditions4Package::invalidAssignmentToErrnoQuery()) and
  assign.getLValue() = errno and
  isErrno(errno) and
  assign.getRValue().getExplicitlyConverted() = rvalue and
  (
    not rvalue instanceof LiteralZero and
    message =
      "Assignment to 'errno' with value '" + rvalue.toString() +
        "' that is not a zero integer literal."
    or
    assign instanceof AssignOperation and
    message =
      "Compound assignment to 'errno' with operator '" + assign.getOperator() + "' is not allowed."
  )
select assign, message
