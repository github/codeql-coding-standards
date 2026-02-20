/**
 * Provides a library which includes a `problems` predicate for reporting catch block shadowing issues.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.exceptions.Shadowing

abstract class CatchBlockShadowingSharedQuery extends Query { }

Query getQuery() { result instanceof CatchBlockShadowingSharedQuery }

query predicate problems(
  ShadowedCatchBlock cbDerived, string message, CatchBlock cbBase, string cbBaseDescription
) {
  not isExcluded(cbDerived, getQuery()) and
  cbBase = cbDerived.getShadowingBlock() and
  message =
    "Catch block for derived type " + cbDerived.getShadowedType() +
      " is shadowed by $@ earlier catch block for base type " + cbDerived.getShadowingType() + "." and
  cbBaseDescription = "this"
}
