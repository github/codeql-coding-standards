/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class NonGlobalFunctionMain_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof NonGlobalFunctionMain_sharedSharedQuery }

query predicate problems(Function f, string message) {
  not isExcluded(f, getQuery()) and
  f.hasName("main") and
  not f.hasGlobalName("main") and
  message = "Identifier main used for a function other than the global function main."
}
