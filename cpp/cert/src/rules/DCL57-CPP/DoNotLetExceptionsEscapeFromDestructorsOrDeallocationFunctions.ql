/**
 * @id cpp/cert/do-not-let-exceptions-escape-from-destructors-or-deallocation-functions
 * @name DCL57-CPP: Do not let exceptions escape from destructors or deallocation functions
 * @description Destructors or deallocation functions that terminate by throwing an exception can
 *              lead to undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/dcl57-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.exceptions.SpecialFunctionExceptions
import ExceptionPathGraph

from
  DestructorOrDeallocatorExceptionThrowingFunction f, ExceptionFlowNode exceptionSource,
  ExceptionFlowNode functionNode, ExceptionType exceptionType
where
  not isExcluded(f,
    Exceptions2Package::doNotLetExceptionsEscapeFromDestructorsOrDeallocationFunctionsQuery()) and
  f.hasExceptionFlow(exceptionSource, functionNode, exceptionType)
select f, exceptionSource, functionNode,
  f.getFunctionType() + " exits with an exception of type " + exceptionType.getExceptionName() + "."
