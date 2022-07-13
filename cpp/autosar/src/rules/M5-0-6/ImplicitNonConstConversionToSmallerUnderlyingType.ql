/**
 * @id cpp/autosar/implicit-non-const-conversion-to-smaller-underlying-type
 * @name M5-0-6: An implicit integral or floating-point conversion shall not reduce the size of the underlying type
 * @description An implicit integral or floating point conversion shall not reduce the size of the
 *              underlying type because this may result in a loss of information.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m5-0-6
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Conversion

predicate underlyingTypesForIntegralConversion(
  MisraConversion::ImplicitIntegralConversion c, IntegralType before, IntegralType after
) {
  before = MisraConversion::getUnderlyingType(c.getExpr()).getUnderlyingType() and
  after = MisraConversion::getUnderlyingType(c).getUnderlyingType()
}

predicate underlyingTypesForFloatingPointConversion(
  FloatingPointConversion c, FloatingPointType before, FloatingPointType after
) {
  before = MisraConversion::getUnderlyingType(c.getExpr()).getUnderlyingType() and
  after = MisraConversion::getUnderlyingType(c).getUnderlyingType()
}

class NonConstImplicitConversion extends Conversion {
  NonConstImplicitConversion() {
    not this.getExpr() instanceof Literal and
    (
      this instanceof MisraConversion::ImplicitIntegralConversion
      or
      this instanceof FloatingPointConversion and this.isImplicit()
    )
  }
}

from
  NonConstImplicitConversion c, ArithmeticType underlyingTypeBefore,
  ArithmeticType underlyingTypeAfter, string kind
where
  not isExcluded(c,
    IntegerConversionPackage::implicitNonConstConversionToSmallerUnderlyingTypeQuery()) and
  (
    underlyingTypesForIntegralConversion(c, underlyingTypeBefore, underlyingTypeAfter) and
    kind = "integral"
    or
    underlyingTypesForFloatingPointConversion(c, underlyingTypeBefore, underlyingTypeAfter) and
    kind = "floating point"
  ) and
  underlyingTypeAfter.getSize() < underlyingTypeBefore.getSize() and
  not c.isInMacroExpansion()
select c,
  "Implicit conversion of " + kind + " $@ reduces the size from " + underlyingTypeBefore.getSize() +
    " bytes to " + underlyingTypeAfter.getSize() + " bytes.", c.getExpr(),
  getConversionExprDescription(c)
