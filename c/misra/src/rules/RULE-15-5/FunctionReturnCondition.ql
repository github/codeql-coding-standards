/**
 * @id c/misra/function-return-condition
 * @name RULE-15-5: A function should have a single point of exit at the end
 * @description Not having a single point of exit in a function can lead to unintentional behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-15-5
 *       maintainability
 *       readability
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

class UserWrittenReturnStmt extends ReturnStmt {
  UserWrittenReturnStmt() { not this.isCompilerGenerated() }
}

from Function func, string message, UserWrittenReturnStmt returnStmt
where
  not isExcluded(func, Statements5Package::functionReturnConditionQuery()) and
  func.hasDefinition() and
  // Ignore functions which have multiple bodies
  count(func.getBlock()) = 1 and
  // Ignore functions which are compiler generated
  not func.isCompilerGenerated() and
  // Report all the return statements in the function
  returnStmt.getEnclosingFunction() = func and
  (
    // There is more than one return statement
    count(UserWrittenReturnStmt return | return.getEnclosingFunction() = func) > 1 and
    message = "Function has more than one $@."
    or
    // There is exactly one return statement
    count(UserWrittenReturnStmt return | return.getEnclosingFunction() = func) = 1 and
    // But it is not the last statement in the function
    not func.getBlock().getLastStmt() instanceof UserWrittenReturnStmt and
    message = "The $@ is not the last statement of the function."
  )
select func, message, returnStmt, "return statement"
