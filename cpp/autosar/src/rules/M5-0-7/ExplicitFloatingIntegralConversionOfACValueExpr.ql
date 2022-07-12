/**
 * @id cpp/autosar/explicit-floating-integral-conversion-of-ac-value-expr
 * @name M5-0-7: There shall be no explicit floating-integral conversions of a cvalue expression
 * @description There shall be no explicit floating-integral conversions of a cvalue expression,
 *              because the conversion doesn't change the type in which the expression is evaluated
 *              and may result in unexpected results.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m5-0-7
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Conversion
import codingstandards.cpp.Expr

from FloatingIntegralConversion c
where
  not isExcluded(c, IntegerConversionPackage::explicitFloatingIntegralConversionOfACValueExprQuery()) and
  not c.isImplicit() and
  c.getExpr() instanceof MisraExpr::CValue
select c, "Explicit conversion of $@ from " + c.getDirection() + ".", c.getExpr(),
  c.getDescription()
