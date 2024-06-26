/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class ResultOfAnAssignmentOperatorShouldNotBeUsed_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof ResultOfAnAssignmentOperatorShouldNotBeUsed_sharedSharedQuery }

query predicate problems(AssignExpr e, string message) {
  not isExcluded(e, getQuery()) and
  not exists(ExprStmt s | s.getExpr() = e) and
  message = "Use of an assignment operator's result."
}
