/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CsignalFunctionsUsed_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof CsignalFunctionsUsed_sharedSharedQuery }

query predicate problems(FunctionCall fc, string message) {
  exists(Function f |
    not isExcluded(fc, getQuery()) and
    f = fc.getTarget() and
    f.hasGlobalOrStdName(["signal", "raise"]) and
    message = "Use of <csignal> function '" + f.getQualifiedName() + "'."
  )
}
