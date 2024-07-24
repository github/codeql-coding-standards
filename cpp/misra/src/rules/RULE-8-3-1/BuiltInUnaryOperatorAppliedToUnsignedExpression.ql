/**
 * @id cpp/misra/built-in-unary-operator-applied-to-unsigned-expression
 * @name RULE-8-3-1: The built-in unary - operator should not be applied to an expression of unsigned type
 * @description The built-in unary - operator should not be applied to an expression of unsigned
 *              type.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-3-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.builtinunaryoperatorappliedtounsignedexpression.BuiltInUnaryOperatorAppliedToUnsignedExpression

class BuiltInUnaryOperatorAppliedToUnsignedExpressionQuery extends BuiltInUnaryOperatorAppliedToUnsignedExpressionSharedQuery
{
  BuiltInUnaryOperatorAppliedToUnsignedExpressionQuery() {
    this = ImportMisra23Package::builtInUnaryOperatorAppliedToUnsignedExpressionQuery()
  }
}
