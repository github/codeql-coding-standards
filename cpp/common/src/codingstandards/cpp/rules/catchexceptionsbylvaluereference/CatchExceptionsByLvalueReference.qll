/**
 * Provides a library which includes a `problems` predicate for reporting class exceptions which are
 * not caught by lvalue reference.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.types.TrivialType
import codingstandards.cpp.exceptions.ExceptionFlow

abstract class CatchExceptionsByLvalueReferenceSharedQuery extends Query { }

Query getQuery() { result instanceof CatchExceptionsByLvalueReferenceSharedQuery }

query predicate problems(Parameter catchParameter, string message) {
  exists(CatchBlock cb, HandlerType catchType |
    not isExcluded(catchParameter, getQuery()) and
    cb.getParameter() = catchParameter and
    catchType = catchParameter.getType() and
    // Find non-lvalue reference types
    not catchType instanceof ReferenceType and
    // Trivial types are permitted
    not isTrivialType(catchType) and
    message =
      "Non trivial type " + catchType.getHandledTypeName() + " is not caught by lvalue reference."
  )
}
