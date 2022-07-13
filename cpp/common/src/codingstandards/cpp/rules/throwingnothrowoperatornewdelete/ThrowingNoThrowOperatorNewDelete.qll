/**
 * Provides a library which includes a `problems` predicate for reporting `nothrow` `operator new`
 * and `operator delete` implementations that actually throw.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.allocations.CustomOperatorNewDelete
import codingstandards.cpp.exceptions.ExceptionFlow
import ExceptionPathGraph

abstract class ThrowingNoThrowOperatorNewDeleteSharedQuery extends Query { }

Query getQuery() { result instanceof ThrowingNoThrowOperatorNewDeleteSharedQuery }

class NoThrowCustomOperatorNewOrDelete extends ExceptionThrowingFunction {
  NoThrowCustomOperatorNewOrDelete() { this.(CustomOperatorNewOrDelete).isNoThrowAllocation() }
}

query predicate problems(
  NoThrowCustomOperatorNewOrDelete opNewDelete, ExceptionFlowNode exceptionSource,
  ExceptionFlowNode functionNode, string message
) {
  not isExcluded(opNewDelete, getQuery()) and
  exists(ExceptionType et |
    opNewDelete.hasExceptionFlow(exceptionSource, functionNode, et) and
    message =
      "Exception of type " + et.getExceptionName() + " thrown by " +
        opNewDelete.(CustomOperatorNewOrDelete).getAllocDescription() +
        " which is declared with nothrow_t parameter."
  )
}
