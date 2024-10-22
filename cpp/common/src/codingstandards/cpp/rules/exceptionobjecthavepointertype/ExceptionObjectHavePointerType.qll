/**
 * Provides a library with a `problems` predicate for the following issue:
 * Throwing an exception of pointer type can lead to use-after-free or memory leak
 * issues.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class ExceptionObjectHavePointerTypeSharedQuery extends Query { }

Query getQuery() { result instanceof ExceptionObjectHavePointerTypeSharedQuery }

query predicate problems(Expr thrownExpr, string message) {
  not isExcluded(thrownExpr, getQuery()) and
  thrownExpr = any(ThrowExpr te).getExpr() and
  thrownExpr.getType().getUnspecifiedType() instanceof PointerType and
  message = "Exception object with pointer type " + thrownExpr.getType() + " is thrown here."
}
