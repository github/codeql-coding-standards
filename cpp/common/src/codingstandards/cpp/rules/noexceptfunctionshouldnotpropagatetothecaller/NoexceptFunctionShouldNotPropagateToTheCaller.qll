/**
 * Provides a library with a `problems` predicate for the following issue:
 * If a function is declared to be noexcept, noexcept(true) or noexcept(<true
 * condition>), then it shall not exit with an exception.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.exceptions.ExceptionFlow
import ExceptionPathGraph
import codingstandards.cpp.exceptions.ExceptionSpecifications

abstract class NoexceptFunctionShouldNotPropagateToTheCallerSharedQuery extends Query { }

Query getQuery() { result instanceof NoexceptFunctionShouldNotPropagateToTheCallerSharedQuery }

class NoExceptThrowingFunction extends ExceptionThrowingFunction {
  NoExceptThrowingFunction() {
    // Can exit with an exception
    exists(getAFunctionThrownType(_, _)) and
    // But is marked noexcept(true) or equivalent
    isNoExceptTrue(this)
  }
}

query predicate problems(
  NoExceptThrowingFunction f, ExceptionFlowNode exceptionSource, ExceptionFlowNode functionNode,
  string message
) {
  exists(ExceptionType exceptionType |
    not isExcluded(f, getQuery()) and
    f.hasExceptionFlow(exceptionSource, functionNode, exceptionType) and
    message =
      "Function " + f.getName() + " is declared noexcept(true) but can throw exceptions of type " +
        exceptionType.getExceptionName() + "."
  )
}
