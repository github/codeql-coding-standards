/**
 * @id cpp/autosar/special-function-exits-with-exception
 * @name A15-5-1: All user-provided class destructors, deallocation functions, move constructors, move assignment operators and swap functions shall not exit with an exception
 * @description All user-provided class destructors, deallocation functions, move constructors, move
 *              assignment operators and swap functions shall not exit with an exception.
 * @kind path-problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a15-5-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.exceptions.SpecialFunctionExceptions
import ExceptionPathGraph

from
  SpecialExceptionThrowingFunction f, ExceptionFlowNode exceptionSource,
  ExceptionFlowNode functionNode, ExceptionType exceptionType
where
  not isExcluded(f, Exceptions2Package::specialFunctionExitsWithExceptionQuery()) and
  f.hasExceptionFlow(exceptionSource, functionNode, exceptionType)
select f, exceptionSource, functionNode,
  f.getFunctionType() + " exits with an exception of type " + exceptionType.getExceptionName() + "."
