/**
 * Provides a library which includes a `problems` predicate for reporting an undefined member access through a null pointer.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Nullness
import codingstandards.cpp.Expr
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

abstract class AccessOfUndefinedMemberThroughNullPointerSharedQuery extends Query { }

Query getQuery() { result instanceof AccessOfUndefinedMemberThroughNullPointerSharedQuery }

query predicate problems(
  PointerToMemberExpr pointerToMemberExpr, DataFlow::PathNode source, DataFlow::PathNode sink,
  string message, Location sourceLocation, string sourceDescription
) {
  not isExcluded(pointerToMemberExpr, getQuery()) and
  message =
    "A null pointer-to-member value from $@ is passed as the second operand to a pointer-to-member expression." and
  sink.getNode().asExpr() = pointerToMemberExpr.getPointerExpr() and
  any(NullPointerToPointerMemberExpressionConfig config).hasFlowPath(source, sink) and
  sourceLocation = source.getNode().getLocation() and
  sourceDescription = "initialization"
}
