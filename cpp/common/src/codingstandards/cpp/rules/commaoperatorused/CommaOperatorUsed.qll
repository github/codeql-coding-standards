/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CommaOperatorUsedSharedQuery extends Query { }

Query getQuery() { result instanceof CommaOperatorUsedSharedQuery }

query predicate problems(CommaExpr comma, string message) {
  not isExcluded(comma, getQuery()) and message = "Use of banned ',' expression."
}
