/**
 * @id c/cert/integer-conversion-causes-data-loss
 * @name INT31-C: Ensure that integer conversions do not result in lost or misinterpreted data
 * @description
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/int31-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

class IntegerConversion extends Expr {
  private IntegralType castedToType;
  private Expr preConversionExpr;

  IntegerConversion() {
    // This is an explicit cast
    castedToType = this.(Cast).getActualType() and
    preConversionExpr = this.(Cast).getExpr()
    or
    // Functions that internally cast an argument to unsigned char
    castedToType instanceof UnsignedCharType and
    this = preConversionExpr and
    exists(FunctionCall call, string name | call.getTarget().hasGlobalOrStdName(name) |
      name = ["ungetc", "fputc"] and
      this = call.getArgument(0)
      or
      name = ["memset", "memchr"] and
      this = call.getArgument(1)
      or
      name = "memset_s" and
      this = call.getArgument(2)
    )
  }

  Expr getPreConversionExpr() { result = preConversionExpr }

  Type getCastedToType() { result = castedToType }
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

from IntegerConversion c, Expr preConversionExpr
where
  not isExcluded(c, IntegerOverflowPackage::integerConversionCausesDataLossQuery()) and
  preConversionExpr = c.getPreConversionExpr() and
  // Casting from an integral type
  preConversionExpr.getType().getUnspecifiedType() instanceof IntegralType and
  // Where the result is not within the range of the target type
  (
    not withinIntegralRange(c.getCastedToType(), lowerBound(preConversionExpr)) or
    not withinIntegralRange(c.getCastedToType(), upperBound(preConversionExpr))
  ) and
  // A conversion of `-1` to `time_t` is permitted by the standard
  not (
    c.getType().getUnspecifiedType().hasName("time_t") and
    preConversionExpr.getValue() = "-1"
  ) and
  // Conversion to unsigned char is permitted from the range [SCHAR_MIN..UCHAR_MAX], as those can
  // legitimately represent characters
  not (
    c.getType().getUnspecifiedType() instanceof UnsignedCharType and
    lowerBound(preConversionExpr) >= typeLowerBound(any(SignedCharType s)) and
    upperBound(preConversionExpr) <= typeUpperBound(any(UnsignedCharType s))
  )
select c,
  "Conversion from " + c.getPreConversionExpr().getType() + " to " + c.getCastedToType() +
    " may cause data loss."
