/**
 * Provides a library with a `problems` predicate for the following issue:
 * The built-in unary - operator should not be applied to an expression of unsigned
 * type.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class BuiltInUnaryOperatorAppliedToUnsignedExpressionSharedQuery extends Query { }

Query getQuery() { result instanceof BuiltInUnaryOperatorAppliedToUnsignedExpressionSharedQuery }

query predicate problems(Element e, string message) {
  exists(UnaryMinusExpr ex, IntegralType t |
    t = ex.getOperand().getExplicitlyConverted().getType().getUnderlyingType() and
    t.isUnsigned() and
    not ex.isAffectedByMacro() and
    e = ex.getOperand() and
    not isExcluded(e, getQuery()) and
    message =
      "The unary minus operator shall not be applied to an expression whose underlying type is unsigned."
  )
}
