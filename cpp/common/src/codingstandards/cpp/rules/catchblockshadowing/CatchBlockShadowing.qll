/**
 * Provides a library which includes a `problems` predicate for reporting catch block shadowing issues.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.exceptions.ExceptionFlow

abstract class CatchBlockShadowingSharedQuery extends Query { }

Query getQuery() { result instanceof CatchBlockShadowingSharedQuery }

query predicate problems(
  CatchBlock cbDerived, string message, CatchBlock cbBase, string cbBaseDescription
) {
  exists(TryStmt try, Class baseType, Class derivedType |
    not isExcluded(cbDerived, getQuery()) and
    exists(int i, int j |
      cbBase = try.getCatchClause(i) and
      cbDerived = try.getCatchClause(j) and
      i < j
    ) and
    baseType = simplifyHandlerType(cbBase.getParameter().getType()) and
    derivedType = simplifyHandlerType(cbDerived.getParameter().getType()) and
    baseType.getADerivedClass+() = derivedType and
    message =
      "Catch block for derived type " + derivedType +
        " is shadowed by $@ earlier catch block for base type " + baseType + "." and
    cbBaseDescription = "this"
  )
}
