/**
 * Provides a library with a `problems` predicate for the following issue:
 * The result of an assignment operator should not be used.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class ResultOfAnAssignmentOperatorShouldNotBeUsedSharedQuery extends Query { }

Query getQuery() { result instanceof ResultOfAnAssignmentOperatorShouldNotBeUsedSharedQuery }

query predicate problems(AssignExpr e, string message) {
  not isExcluded(e, getQuery()) and
  not exists(ExprStmt s | s.getExpr() = e) and
  message = "Use of an assignment operator's result."
}
