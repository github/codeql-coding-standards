/**
 * @id cpp/cert/handle-all-exceptions
 * @name ERR51-CPP: Handle all exceptions
 * @description Exceptions which are not handled by the program can cause the program to abruptly
 *              terminate leaving resources unclosed.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err51-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.exceptions.ExceptionFlow
import ExceptionPathGraph
import codingstandards.cpp.exceptions.UnhandledExceptions

from
  UnhandledExceptionFunction main, ExceptionFlowNode exceptionSource,
  ExceptionFlowNode functionNode, ExceptionType exceptionType
where
  not isExcluded(main, Exceptions1Package::handleAllExceptionsQuery()) and
  main.hasExceptionFlow(exceptionSource, functionNode, exceptionType)
select main, exceptionSource, functionNode,
  "Exceptions of type '" + exceptionType.getExceptionName() +
    "' are thrown and not caught in this main-like function."
