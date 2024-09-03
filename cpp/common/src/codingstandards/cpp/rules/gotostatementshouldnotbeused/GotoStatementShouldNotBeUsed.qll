/**
 * Provides a library with a `problems` predicate for the following issue:
 * The goto statement shall not be used.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class GotoStatementShouldNotBeUsedSharedQuery extends Query { }

Query getQuery() { result instanceof GotoStatementShouldNotBeUsedSharedQuery }

query predicate problems(Stmt s, string message) {
  not isExcluded(s, getQuery()) and
  (s instanceof GotoStmt or s instanceof ComputedGotoStmt) and
  message = "Use of goto."
}
