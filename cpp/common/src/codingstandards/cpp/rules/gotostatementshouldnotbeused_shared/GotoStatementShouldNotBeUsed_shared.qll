/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class GotoStatementShouldNotBeUsed_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof GotoStatementShouldNotBeUsed_sharedSharedQuery }

query predicate problems(Stmt s, string message) {
  not isExcluded(s, getQuery()) and
  (s instanceof GotoStmt or s instanceof ComputedGotoStmt) and
  message = "Use of goto."
}
