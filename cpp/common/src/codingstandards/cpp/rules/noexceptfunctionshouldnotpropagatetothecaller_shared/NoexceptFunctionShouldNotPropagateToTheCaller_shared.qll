/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.exceptions.ExceptionFlow
import ExceptionPathGraph
import codingstandards.cpp.exceptions.ExceptionSpecifications

abstract class NoexceptFunctionShouldNotPropagateToTheCaller_sharedSharedQuery extends Query { }

Query getQuery() {
  result instanceof NoexceptFunctionShouldNotPropagateToTheCaller_sharedSharedQuery
}

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
