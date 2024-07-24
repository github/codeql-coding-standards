/**
 * Provides a library with a `problems` predicate for the following issue:
 * Casts shall not be performed between a pointer to function and any other type.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CastsBetweenAPointerToFunctionAndAnyOtherTypeSharedQuery extends Query { }

Query getQuery() { result instanceof CastsBetweenAPointerToFunctionAndAnyOtherTypeSharedQuery }

query predicate problems(Cast c, string message) {
  not isExcluded(c, getQuery()) and
  not c.isImplicit() and
  not c.isAffectedByMacro() and
  c.getExpr().getType() instanceof FunctionPointerType and
  message = "Cast converting a pointer to function."
}
