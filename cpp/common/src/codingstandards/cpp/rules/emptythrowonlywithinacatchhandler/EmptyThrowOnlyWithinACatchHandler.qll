/**
 * Provides a library with a `problems` predicate for the following issue:
 * Empty throws with no currently handled exception can cause abrupt program
 * termination.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class EmptyThrowOnlyWithinACatchHandlerSharedQuery extends Query { }

Query getQuery() { result instanceof EmptyThrowOnlyWithinACatchHandlerSharedQuery }

query predicate problems(ReThrowExpr re, string message) {
  not isExcluded(re, getQuery()) and
  not re.getEnclosingElement+() instanceof CatchBlock and
  message = "Rethrow outside catch block"
}
