/**
 * Provides a library with a `problems` predicate for the following issue:
 * The statement reinterpret_cast shall not be used.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class ReinterpretCastUsedSharedQuery extends Query { }

Query getQuery() { result instanceof ReinterpretCastUsedSharedQuery }

query predicate problems(ReinterpretCast rc, string message) {
  not isExcluded(rc, getQuery()) and message = "Use of reinterpret_cast."
}
