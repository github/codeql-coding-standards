/**
 * Provides a library which includes a `problems` predicate for reporting
 * `void* operator new(size_t)` implementations that return `null`.
 */

import cpp
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.allocations.CustomOperatorNewDelete
import codingstandards.cpp.exceptions.ExceptionSpecifications
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import NullFlow::PathGraph

abstract class ThrowingOperatorNewReturnsNullSharedQuery extends Query { }

Query getQuery() { result instanceof ThrowingOperatorNewReturnsNullSharedQuery }

module NullConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof NullValue
    or
    // Call to an allocation function that may return null
    exists(FunctionCall fc |
      fc = source.asExpr().(NewOrNewArrayExpr).getAllocatorCall()
      or
      fc = source.asExpr() and
      fc.getTarget().getName().regexpMatch("operator new(\\[\\])?")
    |
      isNoExceptTrue(fc.getTarget())
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(CustomOperatorNew co, ReturnStmt rs |
      co.getNumberOfParameters() = 1 and
      rs.getEnclosingFunction() = co and
      rs.getExpr() = sink.asExpr()
    )
  }
}

module NullFlow = DataFlow::Global<NullConfig>;

query predicate problems(
  ReturnStmt e, NullFlow::PathNode source, NullFlow::PathNode sink, string message
) {
  not isExcluded(e, getQuery()) and
  NullFlow::flowPath(source, sink) and
  sink.getNode().asExpr() = e.getExpr() and
  exists(CustomOperatorNew op |
    message =
      op.getAllocDescription() + " may return null instead of throwing a std::bad_alloc exception."
  )
}
