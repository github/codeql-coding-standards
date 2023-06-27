/**
 * @id cpp/autosar/missing-catch-handler-in-main
 * @name A15-3-3: Main like functions should catch all relevant base class and unhandled exceptions
 * @description Main function and a task main function shall catch at least: base class exceptions
 *              from all third-party libraries used, std::exception and all otherwise unhandled
 *              exceptions.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a15-3-3
 *       maintainability
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.exceptions.ThirdPartyExceptions
import codingstandards.cpp.standardlibrary.Exceptions
import codingstandards.cpp.EncapsulatingFunctions

/*
 * The strategy for this query is to find a Stmt in the root BlockStmt which can throw one of the
 * ExceptionTypes that should be handled.
 */

from MainLikeFunction main, ExceptionType uncaughtExceptionType
where
  not isExcluded(main, Exceptions1Package::missingCatchHandlerInMainQuery()) and
  exists(Stmt bodyStmt |
    // Find a direct child Stmt of the function body block
    bodyStmt = main.getBlock().getAStmt() and
    // Exclude simple return statements, which we allow to occur outside try/catches.
    not exists(bodyStmt.(ReturnStmt).getExpr().getValue()) and
    // Identify an exception type that should be handled at this Stmt
    (
      // std::exception should always be caught
      uncaughtExceptionType instanceof StdException
      or
      // third party base type exceptions should always be caught
      uncaughtExceptionType instanceof ThirdPartyBaseExceptionType
      or
      // An unhandled exception thrown by an expression within this statement, that is not covered
      // under the other two cases
      exists(ThrowingExpr te |
        uncaughtExceptionType = getAFunctionThrownType(main, te) and
        te.getEnclosingStmt().getParentStmt*() = bodyStmt and
        not uncaughtExceptionType.(Class).getABaseClass*() instanceof StdException and
        not uncaughtExceptionType.(Class).getABaseClass*() instanceof ThirdPartyBaseExceptionType
      )
    ) and
    // No handler exists which catches that exception type for this Stmt
    not exists(CatchBlock cb |
      cb.getEnclosingFunction() = main and
      isCaught(cb, uncaughtExceptionType)
    |
      cb.getTryStmt() = bodyStmt
      or
      cb.getTryStmt() instanceof FunctionTryStmt
    )
  )
// We do not report each of the bodyStmts that could throw, because it would be very noisy in the
// case of large main functions with no try-catch handlers
select main,
  "Main-like function does not include a handler for " + uncaughtExceptionType.getExceptionName() +
    "."
