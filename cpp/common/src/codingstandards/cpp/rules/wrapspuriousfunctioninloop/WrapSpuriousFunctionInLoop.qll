/**
 * Provides a library which includes a `problems` predicate for reporting
 * functions that should be wrapped in a loop because they may wake up spuriously.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Concurrency

abstract class WrapSpuriousFunctionInLoopSharedQuery extends Query { }

Query getQuery() { result instanceof WrapSpuriousFunctionInLoopSharedQuery }

query predicate problems(ConditionalWait cw, string message) {
  not isExcluded(cw, getQuery()) and
  not cw.getEnclosingStmt().getParentStmt*() instanceof Loop and
  message = "Use of a function that may wake up spuriously without a controlling loop."
}
