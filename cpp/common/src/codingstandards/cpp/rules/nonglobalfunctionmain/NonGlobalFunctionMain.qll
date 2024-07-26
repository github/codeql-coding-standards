/**
 * Provides a library with a `problems` predicate for the following issue:
 * The identifier main shall not be used for a function other than the global function
 * main.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class NonGlobalFunctionMainSharedQuery extends Query { }

Query getQuery() { result instanceof NonGlobalFunctionMainSharedQuery }

query predicate problems(Function f, string message) {
  not isExcluded(f, getQuery()) and
  f.hasName("main") and
  not f.hasGlobalName("main") and
  message = "Identifier main used for a function other than the global function main."
}
