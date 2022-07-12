/**
 * @id cpp/autosar/exception-thrown-on-completion
 * @name A15-0-1: A function shall not exit with an exception if it is able to complete its task
 * @description Exceptions should be used to only model exceptional flow.
 * @kind problem
 * @precision low
 * @problem.severity recommendation
 * @tags external/autosar/id/a15-0-1
 *       maintainability
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/audit
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.ExceptionFlow

from Function f, ExceptionType et, ThrowingExpr throwingExpr
where
  not isExcluded(throwingExpr, Exceptions1Package::exceptionThrownOnCompletionQuery()) and
  et = getAFunctionThrownType(f, throwingExpr)
select throwingExpr,
  "[AUDIT] Function $@ throws an exception of type '" + et.getExceptionName() + "'.", f, f.getName()
