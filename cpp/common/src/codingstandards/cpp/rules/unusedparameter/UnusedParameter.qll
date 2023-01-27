/**
 * Provides a library which includes a `problems` predicate for reporting unused parameters.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.deadcode.UnusedParameters

abstract class UnusedParameterSharedQuery extends Query { }

Query getQuery() { result instanceof UnusedParameterSharedQuery }

query predicate problems(UnusedParameter p, string message, Function f, string fName) {
  not isExcluded(p, getQuery()) and
  f = p.getFunction() and
  // Virtual functions are covered by a different rule
  not f.isVirtual() and
  message = "Unused parameter '" + p.getName() + "' for function $@." and
  fName = f.getQualifiedName()
}
