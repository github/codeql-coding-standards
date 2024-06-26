/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class ReinterpretCastUsed_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof ReinterpretCastUsed_sharedSharedQuery }

query predicate problems(ReinterpretCast rc, string message) {
  not isExcluded(rc, getQuery()) and message = "Use of reinterpret_cast."
}
