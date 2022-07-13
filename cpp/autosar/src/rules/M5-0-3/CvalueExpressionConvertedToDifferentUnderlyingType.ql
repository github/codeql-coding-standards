/**
 * @id cpp/autosar/cvalue-expression-converted-to-different-underlying-type
 * @name M5-0-3: A cvalue expression shall not be implicitly converted to a different underlying type
 * @description In order to ensure all operations in an expression are performed in the same
 *              underlying type, an expression defined as a cvalue shall not undergo further
 *              implicit conversions.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-0-3
 *       correctness
 *       external/autosar/strict
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Expr
import codingstandards.cpp.Conversion

from Expr e, MisraExpr::CValue cvalue, ArithmeticType before, ArithmeticType after
where
  not isExcluded(e, ExpressionsPackage::cvalueExpressionConvertedToDifferentUnderlyingTypeQuery()) and
  (
    exists(Conversion c | c = e |
      c.getExpr() = cvalue and
      c.isImplicit() and
      not c instanceof IntegralPromotion and
      after = MisraConversion::getUnderlyingType(c)
    )
    or
    exists(Assignment a |
      a.getRValue() = e and
      a.getRValue() = cvalue and
      after = MisraConversion::getUnderlyingType(a)
    )
  ) and
  before = MisraConversion::getUnderlyingType(cvalue) and
  not before = after
select e,
  "Implicit conversion converts cvalue $@ from " + before.toString() + " to " + after.toString() +
    ".", cvalue, "expression"
