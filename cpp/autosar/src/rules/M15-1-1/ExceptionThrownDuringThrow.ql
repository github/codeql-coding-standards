/**
 * @id cpp/autosar/exception-thrown-during-throw
 * @name M15-1-1: The assignment-expression of a throw statement shall not itself cause an exception to be thrown
 * @description Exceptions thrown from the assignment-expression will be propagated instead of the
 *              original exception.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/m15-1-1
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.ExceptionFlow

from ThrowExpr te, ThrowingExpr throwingExpr, ExceptionType exceptionType
where
  not isExcluded(te, Exceptions1Package::exceptionThrownDuringThrowQuery()) and
  te.getExpr().getAChild*() = throwingExpr and
  exceptionType = throwingExpr.getAnExceptionType()
select throwingExpr,
  "This expression is within a $@, but can itself throw type " + exceptionType.getExceptionName() +
    ".", te, "throw"
