/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class EmptyThrowOnlyWithinACatchHandler_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof EmptyThrowOnlyWithinACatchHandler_sharedSharedQuery }

query predicate problems(ReThrowExpr re, string message) {
  not isExcluded(re, getQuery()) and
  not re.getEnclosingElement+() instanceof CatchBlock and
  message = "Rethrow outside catch block"
}
