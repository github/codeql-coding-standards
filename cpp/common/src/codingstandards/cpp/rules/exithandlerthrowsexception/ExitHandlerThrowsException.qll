/**
 * Provides a library which includes a `problems` predicate for reporting exit handlers that throw
 * exceptions.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.exceptions.ExceptionFlow
import ExceptionPathGraph

abstract class ExitHandlerThrowsExceptionSharedQuery extends Query { }

Query getQuery() { result instanceof ExitHandlerThrowsExceptionSharedQuery }

class ExitHandler extends ExceptionThrowingFunction {
  Call c;

  ExitHandler() {
    c.getTarget().hasGlobalOrStdName(["atexit", "at_quick_exit"]) and
    c.getArgument(0) = this.getAnAccess()
  }

  Call getARegistrationCall() { result = c }
}

query predicate problems(
  ExitHandler exitHandler, ExceptionFlowNode exceptionSource, ExceptionFlowNode functionNode,
  string message, FunctionCall registrationCall, string registrationCallDescription
) {
  exists(ExceptionType et |
    not isExcluded(exitHandler, getQuery()) and
    exitHandler.hasExceptionFlow(exceptionSource, functionNode, et) and
    message = "This function is $@ and can throw an exception of type " + et.getExceptionName() and
    registrationCall = exitHandler.getARegistrationCall() and
    registrationCallDescription = "registered as an exit handler"
  )
}
