/**
 * Provides a library with a `problems` predicate for the following issue:
 * The comma operator shall not be used.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CommaOperatorUsedSharedQuery extends Query { }

Query getQuery() { result instanceof CommaOperatorUsedSharedQuery }

query predicate problems(CommaExpr comma, string message) {
  not isExcluded(comma, getQuery()) and message = "Use of banned ',' expression."
}
