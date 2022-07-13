/**
 * @id cpp/autosar/unary-minus-operator-applied-to-an-expression-whose-underlying-type-is-unsigned
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

from UnaryMinusExpr e, IntegralType t
where
  not isExcluded(e,
    OperatorsPackage::unaryMinusOperatorAppliedToAnExpressionWhoseUnderlyingTypeIsUnsignedQuery()) and
  t = e.getOperand().getExplicitlyConverted().getType().getUnderlyingType() and
  t.isUnsigned() and
  not e.isAffectedByMacro()
select e.getOperand(),
  "The unary minus operator shall not be applied to an expression whose underlying type is unsigned."
