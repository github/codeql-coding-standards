/**
 * @id cpp/autosar/no-except-function-throws
 * @name A15-4-2: A function declared to be noexcept(true) shall not exit with an exception
 * @description If a function is declared to be noexcept, noexcept(true) or noexcept(<true
 *              condition>), then it shall not exit with an exception.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a15-4-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.ExceptionFlow
import ExceptionPathGraph
import codingstandards.cpp.exceptions.ExceptionSpecifications

class NoExceptThrowingFunction extends ExceptionThrowingFunction {
  NoExceptThrowingFunction() {
    // Can exit with an exception
    exists(getAFunctionThrownType(_, _)) and
    // But is marked noexcept(true) or equivalent
    isNoExceptTrue(this)
  }
}

from
  NoExceptThrowingFunction f, ExceptionFlowNode exceptionSource, ExceptionFlowNode functionNode,
  ExceptionType exceptionType
where
  not isExcluded(f, Exceptions1Package::noExceptFunctionThrowsQuery()) and
  f.hasExceptionFlow(exceptionSource, functionNode, exceptionType)
select f, exceptionSource, functionNode,
  "Function " + f.getName() + " is declared noexcept(true) but can throw exceptions of type " +
    exceptionType.getExceptionName() + "."
