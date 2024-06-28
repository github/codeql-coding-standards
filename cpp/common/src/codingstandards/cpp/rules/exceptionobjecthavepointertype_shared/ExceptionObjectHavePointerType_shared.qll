/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class ExceptionObjectHavePointerType_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof ExceptionObjectHavePointerType_sharedSharedQuery }

query predicate problems(Expr thrownExpr, string message) {
  not isExcluded(thrownExpr, getQuery()) and
  thrownExpr = any(ThrowExpr te).getExpr() and
  thrownExpr.getType().getUnspecifiedType() instanceof PointerType and
  message = "Exception object with pointer type " + thrownExpr.getType() + " is thrown here."
}
