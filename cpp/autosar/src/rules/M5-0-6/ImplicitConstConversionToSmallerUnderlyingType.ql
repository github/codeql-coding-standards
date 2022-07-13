/**
 * @id cpp/autosar/implicit-const-conversion-to-smaller-underlying-type
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

class ConstImplicitConversion extends Conversion {
  ConstImplicitConversion() {
    this.getExpr() instanceof Literal and
    (
      this instanceof MisraConversion::ImplicitIntegralConversion
      or
      this instanceof FloatingPointConversion and this.isImplicit()
    )
  }
}

bindingset[value]
predicate withinIntegralRange(IntegralType typ, float value) {
  exists(float lb, float ub, float limit |
    limit = 2.pow(8 * typ.getSize()) and
    (
      if typ.isUnsigned()
      then (
        lb = 0 and ub = limit - 1
      ) else (
        lb = -limit / 2 and
        ub = (limit / 2) - 1
      )
    ) and
    value >= lb and
    value <= ub
  )
}

/**
 * Holds if the float `value` is within the range of the float `typ`.
 * This is a heuristic since the floating point representation is implementation defined and our
 * aim is to reduce results for common values such as 0.0.
 */
bindingset[value]
predicate withinFloatRange(FloatingPointType typ, float value) {
  typ.getSize() = [4, 8] and value >= -1000 and value <= 1000
}

from
  ConstImplicitConversion c, ArithmeticType underlyingTypeBefore,
  ArithmeticType underlyingTypeAfter, string kind
where
  not isExcluded(c,
    IntegerConversionPackage::implicitNonConstConversionToSmallerUnderlyingTypeQuery()) and
  (
    c instanceof IntegralConversion and
    not withinIntegralRange(c.getUnderlyingType(), c.getExpr().getValue().toFloat()) and
    kind = "integral"
    or
    c instanceof FloatingPointConversion and
    not withinFloatRange(c.getUnderlyingType(), c.getExpr().getValue().toFloat()) and
    kind = "floating point"
  ) and
  underlyingTypeBefore = c.getExpr().getType().getUnderlyingType() and
  underlyingTypeAfter = c.getType().getUnderlyingType() and
  underlyingTypeAfter.getSize() < underlyingTypeBefore.getSize() and
  not c.isInMacroExpansion()
select c,
  "Implicit conversion of " + kind + " $@ reduces the size from " + underlyingTypeBefore.getSize() +
    " bytes to " + underlyingTypeAfter.getSize() + " bytes.", c.getExpr(),
  getConversionExprDescription(c)
