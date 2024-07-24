/**
 * @id cpp/autosar/unary-minus-operator-applied-to-an-unsigned-expression
 * @name M5-3-2: The unary minus operator shall not be applied to an expression whose underlying type is unsigned
 * @description The unary minus operator shall not be applied to an expression whose underlying type
 *              is unsigned.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-3-2
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.builtinunaryoperatorappliedtounsignedexpression.BuiltInUnaryOperatorAppliedToUnsignedExpression

class UnaryMinusOperatorAppliedToAnUnsignedExpressionQuery extends BuiltInUnaryOperatorAppliedToUnsignedExpressionSharedQuery
{
  UnaryMinusOperatorAppliedToAnUnsignedExpressionQuery() {
    this = OperatorsPackage::unaryMinusOperatorAppliedToAnUnsignedExpressionQuery()
  }
}
