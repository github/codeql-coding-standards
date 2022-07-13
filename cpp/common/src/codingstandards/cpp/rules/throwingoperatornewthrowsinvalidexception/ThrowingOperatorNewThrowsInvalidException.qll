/**
 * Provides a library which includes a `problems` predicate for reporting `operator new`
 * and implementations that actually throw exceptions other than `std::bad_alloc`.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.allocations.CustomOperatorNewDelete
import codingstandards.cpp.exceptions.ExceptionFlow
import ExceptionPathGraph

abstract class ThrowingOperatorNewThrowsInvalidExceptionSharedQuery extends Query { }

Query getQuery() { result instanceof ThrowingOperatorNewThrowsInvalidExceptionSharedQuery }

class ThrowingCustomOperatorNew extends ExceptionThrowingFunction {
  CustomOperatorNew op;

  ThrowingCustomOperatorNew() {
    this = op and
    not op.isNoThrowAllocation()
  }
}

query predicate problems(
  ThrowingCustomOperatorNew opNewDelete, ExceptionFlowNode exceptionSource,
  ExceptionFlowNode functionNode, string message
) {
  not isExcluded(opNewDelete, getQuery()) and
  exists(ExceptionType et |
    opNewDelete.hasExceptionFlow(exceptionSource, functionNode, et) and
    not et.(Class).hasQualifiedName("std", "bad_alloc") and
    message =
      "Exception of type " + et.getExceptionName() + " thrown by " +
        opNewDelete.(CustomOperatorNewOrDelete).getAllocDescription() +
        " which is declared with nothrow_t parameter."
  )
}
