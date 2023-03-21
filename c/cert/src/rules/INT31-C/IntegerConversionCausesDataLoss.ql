/**
 * @id c/cert/integer-conversion-causes-data-loss
 * @name INT31-C: Ensure that integer conversions do not result in lost or misinterpreted data
 * @description Converting an integer value to another integer type with a different sign or size
 *              can lead to data loss or misinterpretation of the value.
 * @kind problem
 * @precision medium
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
    castedToType = this.(Cast).getType().getUnspecifiedType() and
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

from
  IntegerConversion c, Expr preConversionExpr, Type castedToType, Type castedFromType,
  IntegralType unspecifiedCastedFromType, string typeFromMessage, float preConversionLowerBound,
  float preConversionUpperBound, float typeLowerBound, float typeUpperBound
where
  not isExcluded(c, IntegerOverflowPackage::integerConversionCausesDataLossQuery()) and
  preConversionExpr = c.getPreConversionExpr() and
  castedFromType = preConversionExpr.getType() and
  // Casting from an integral type
  unspecifiedCastedFromType = castedFromType.getUnspecifiedType() and
  // Casting to an integral type
  castedToType = c.getCastedToType() and
  // Get the upper/lower bound of the pre-conversion expression
  preConversionLowerBound = lowerBound(preConversionExpr) and
  preConversionUpperBound = upperBound(preConversionExpr) and
  // Get the upper/lower bound of the target type
  typeLowerBound = typeLowerBound(castedToType) and
  typeUpperBound = typeUpperBound(castedToType) and
  // Where the result is not within the range of the target type
  (
    not withinIntegralRange(castedToType, preConversionLowerBound) or
    not withinIntegralRange(castedToType, preConversionUpperBound)
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
  ) and
  not castedToType instanceof BoolType and
  // Create a helpful message
  if castedFromType = unspecifiedCastedFromType
  then typeFromMessage = castedFromType.toString()
  else typeFromMessage = castedFromType + " (" + unspecifiedCastedFromType + ")"
select c,
  "Conversion from " + typeFromMessage + " to " + castedToType +
    " may cause data loss (casting from range " + preConversionLowerBound + "..." +
    preConversionUpperBound + " to range " + typeLowerBound + "..." + typeUpperBound + ")."
