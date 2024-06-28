/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class LoopCompoundCondition_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof LoopCompoundCondition_sharedSharedQuery }

query predicate problems(Loop loop, string message) {
  not isExcluded(loop, getQuery()) and
  not loop.getStmt() instanceof BlockStmt and
  message = "Loop body not enclosed within braces."
}
