/**
 * Provides a library with a `problems` predicate for the following issue:
 * Signal handling contains implementation-defined and undefined behaviour.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CsignalFunctionsUsedSharedQuery extends Query { }

Query getQuery() { result instanceof CsignalFunctionsUsedSharedQuery }

query predicate problems(FunctionCall fc, string message) {
  exists(Function f |
    not isExcluded(fc, getQuery()) and
    f = fc.getTarget() and
    f.hasGlobalOrStdName(["signal", "raise"]) and
    message = "Use of <csignal> function '" + f.getQualifiedName() + "'."
  )
}
