/**
 * @id cpp/autosar/explicit-widening-conversion-of-ac-value-expr
 * @name M5-0-8: An explicit integral or floating-point conversion shall not increase the size of the underlying type
 * @description An explicit integral or floating-point conversion shall not increase the size of the
 *              underlying type of a cvalue expression, because the application of the cast to the
 *              result of an expression does not influence the type in which the expression is
 *              evaluated.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m5-0-8
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Expr
import codingstandards.cpp.Conversion

predicate determineTypes(
  MisraConversion::ExplicitCValueConversion c, ArithmeticType before, ArithmeticType after
) {
  before = MisraConversion::getUnderlyingType(c.getCValue()).getUnspecifiedType() and
  after = c.getUnderlyingType()
}

from MisraConversion::ExplicitCValueConversion c, ArithmeticType before, ArithmeticType after
where
  not isExcluded(c, IntegerConversionPackage::explicitWideningConversionOfACValueExprQuery()) and
  not c.isImplicit() and
  determineTypes(c, before, after) and
  before.getSize() < after.getSize() and
  not c.isInMacroExpansion()
select c,
  "Explicit conversion increases the size of $@ from " + before.getSize().toString() + " to " +
    after.getSize().toString() + ".", c.getCValue(), getConversionExprDescription(c)
