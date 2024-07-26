/**
 * Provides a library with a `problems` predicate for the following issue:
 * If the body of a loop is not enclosed in braces, then this can lead to incorrect
 * execution, and hard for developers to maintain.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class LoopCompoundConditionSharedQuery extends Query { }

Query getQuery() { result instanceof LoopCompoundConditionSharedQuery }

query predicate problems(Loop loop, string message) {
  not isExcluded(loop, getQuery()) and
  not loop.getStmt() instanceof BlockStmt and
  message = "Loop body not enclosed within braces."
}
