/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CastsBetweenAPointerToFunctionAndAnyOtherType_sharedSharedQuery extends Query { }

Query getQuery() {
  result instanceof CastsBetweenAPointerToFunctionAndAnyOtherType_sharedSharedQuery
}

query predicate problems(Cast c, string message) {
  not isExcluded(c, getQuery()) and
  not c.isImplicit() and
  not c.isAffectedByMacro() and
  c.getExpr().getType() instanceof FunctionPointerType and
  message = "Cast converting a pointer to function."
}
