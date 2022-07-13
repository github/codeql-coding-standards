/**
 * @id cpp/autosar/catch-all-explicitly-thrown-exceptions
 * @name M15-3-4: Each exception explicitly thrown in the code shall have a handler of a compatible type in all call paths that could lead to that point
 * @description An unhandled exception leads to abrupt program termination.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/m15-3-4
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.UnhandledExceptions
import codingstandards.cpp.exceptions.ExceptionFlow
import ExceptionPathGraph

// Note: This is similar to the CERT C++ rule ERR51-CPP ("Handle all exceptions"), but differs in two key ways:
//  1. We only report _explicitly_ thrown exceptions
//  2. We report the throw itself, rather than the main function
from
  ThrowExpr te, UnhandledExceptionFunction main, ExceptionFlowNode exceptionSource,
  ExceptionFlowNode functionNode, ExceptionType exceptionType
where
  not isExcluded(te, Exceptions1Package::catchAllExplicitlyThrownExceptionsQuery()) and
  main.hasExceptionFlow(exceptionSource, functionNode, exceptionType) and
  te = exceptionSource.asThrowingExpr()
select te, exceptionSource, functionNode,
  "Exception of type '" + exceptionType.getExceptionName() +
    "' is thrown here and not caught on at least one path to this $@.", main, "main-like function"
