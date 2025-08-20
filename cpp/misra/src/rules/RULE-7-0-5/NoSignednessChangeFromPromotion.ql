/**
 * @id cpp/misra/no-signedness-change-from-promotion
 * @name RULE-7-0-5: Integral promotion and the usual arithmetic conversions shall not change the signedness or the type
 * @description Integral promotion and usual arithmetic conversions that change operand signedness
 *              or type category may cause unexpected behavior or undefined behavior when operations
 *              overflow.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-0-5
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.misra.BuiltInTypeRules

/**
 * An expression that represents a integral promotion or usual arithmetic conversion.
 *
 * Such conversions are usual either explicitly described with a `Cast`, or, in the case
 * of assign operations, implicitly applied to an lvalue.
 */
abstract class IntegerPromotionOrUsualArithmeticConversion extends Expr {
  abstract NumericType getFromType();

  abstract NumericType getToType();

  abstract Expr getConvertedExpr();

  abstract string getKindOfConversion();
}

/**
 * A `Cast` which is either an integer promotion or usual arithmetic conversion.
 */
abstract class IntegerPromotionOrUsualArithmeticConversionAsCast extends IntegerPromotionOrUsualArithmeticConversion,
  Cast
{
  NumericType fromType;
  NumericType toType;

  IntegerPromotionOrUsualArithmeticConversionAsCast() {
    fromType = this.getExpr().getType() and
    toType = this.getType() and
    this.isImplicit()
  }

  override NumericType getFromType() { result = fromType }

  override NumericType getToType() { result = toType }

  override Expr getConvertedExpr() { result = this.getExpr() }
}

class UsualArithmeticConversion extends IntegerPromotionOrUsualArithmeticConversionAsCast {
  UsualArithmeticConversion() {
    (
      // Most binary operations from and to numeric types participate in usual arithmetic conversions
      exists(BinaryOperation op |
        // Shifts do not participate in usual arithmetic conversions
        not op instanceof LShiftExpr and
        not op instanceof RShiftExpr and
        op.getAnOperand().getFullyConverted() = this
      )
      or
      // Most binary assignment operations from and to numeric types participate in usual arithmetic
      // conversions
      exists(AssignOperation ao |
        // Shifts do not participate in usual arithmetic conversions
        not ao instanceof AssignLShiftExpr and
        not ao instanceof AssignRShiftExpr and
        ao.getRValue().getFullyConverted() = this
      )
    )
  }

  override string getKindOfConversion() { result = "Usual arithmetic conversion" }
}

class IntegerPromotion extends IntegerPromotionOrUsualArithmeticConversionAsCast {
  IntegerPromotion() {
    // In the case where a conversion involves both an integer promotion and a usual arithmetic conversion
    // we only get a single `Conversion` which combines both. According to the rule, only the "final" type
    // should be consider, so we handle these combined conversions as `UsualArithmeticConversion`s instead.
    not this instanceof UsualArithmeticConversion and
    // Only consider cases where the integer promotion is the last conversion applied
    exists(Expr e | e.getFullyConverted() = this) and
    // Integer promotion occurs where the from type is smaller than int
    fromType.getRealSize() < sizeOfInt() and
    // To type is bigger than or equal to int
    toType.getRealSize() >= sizeOfInt() and
    // An integer promotion is a conversion from an integral type to an integral type
    //
    // This deliberately excludes integer promotions from `bool` and unscoped enums which do not
    // have a fixed underlying type, because neither of these are considered integral types in the
    // MISRA C++ rules.
    fromType.getTypeCategory() = Integral() and
    toType.getTypeCategory() = Integral()
  }

  override string getKindOfConversion() { result = "Integer promotion" }
}

class ImpliedUsualArithmeticConversion extends IntegerPromotionOrUsualArithmeticConversion {
  NumericType fromType;
  NumericType toType;

  ImpliedUsualArithmeticConversion() {
    // The lvalue of an assignment operation does not have a `Conversion` in our model, but
    // it is still subject to usual arithmetic conversions (excepting shifts).
    //
    // rvalues are handled separately in the `UsualArithmeticConversion` class.
    exists(AssignOperation aop |
      not aop instanceof AssignLShiftExpr and
      not aop instanceof AssignRShiftExpr and
      // lvalue subject to usual arithmetic conversions
      aop.getLValue() = this and
      // From type is the type of the lvalue, which should be a numeric type under the MISRA rule
      fromType = this.getType() and
      // Under usual arithmetic conversions, the converted types of both arguments will be the same,
      // so even though we don't have an explicit conversion, we can still deduce that the target
      // type will be the same as the converted type of the rvalue.
      toType = aop.getRValue().getFullyConverted().getType() and
      // Only consider cases where the conversion is not a no-op, for consistency with the `Conversion` class
      not fromType.getRealType() = toType.getRealType()
    )
  }

  override NumericType getFromType() { result = fromType }

  override NumericType getToType() { result = toType }

  override Expr getConvertedExpr() { result = this }

  override string getKindOfConversion() { result = "Usual arithmetic conversion" }
}

class ImpliedIntegerPromotion extends IntegerPromotionOrUsualArithmeticConversion {
  NumericType fromType;

  ImpliedIntegerPromotion() {
    (
      exists(AssignLShiftExpr aop | aop.getLValue() = this) or
      exists(AssignRShiftExpr aop | aop.getLValue() = this)
    ) and
    // The rule applies to integer promotions from and to MISRA C++ numeric types
    // However, you cannot have an integer promotion on a float, so we restrict
    // this to integral types only
    fromType = this.getType() and
    fromType.getTypeCategory() = Integral() and
    // If the size is less than int, then it is an implied integer promotion
    fromType.getRealSize() < sizeOfInt()
  }

  override NumericType getFromType() { result = fromType }

  override CanonicalIntegerNumericType getToType() {
    // Only report the canonical type - e.g. `int` not `signed int`
    if result instanceof Char16Type or result instanceof Char32Type or result instanceof Wchar_t
    then
      // Smallest type that can hold the value of the `fromType`
      result =
        min(NumericType candidateType |
          (
            candidateType instanceof IntType or
            candidateType instanceof LongType or
            candidateType instanceof LongLongType
          ) and
          fromType.getIntegralUpperBound() <= candidateType.getIntegralUpperBound()
        |
          candidateType order by candidateType.getIntegralUpperBound()
        )
    else (
      if
        // If the `fromType` is signed, the result must be signed
        fromType.getSignedness() = Signed()
        or
        // If the `fromType` is unsigned, but the result can fit into the signed int type, then the
        // result must be signed as well.
        fromType.getIntegralUpperBound() <=
          any(IntType t | t.isSigned()).(NumericType).getIntegralUpperBound()
      then
        // `int` is returned
        result.(IntType).isSigned()
      else
        // Otherwise `unsigned int` is returned
        result.(IntType).isUnsigned()
    )
  }

  override Expr getConvertedExpr() { result = this }

  override string getKindOfConversion() { result = "Integer promotion" }
}

from
  Expr e, IntegerPromotionOrUsualArithmeticConversion c, NumericType fromType, NumericType toType,
  string changeType
where
  not isExcluded(e, ConversionsPackage::noSignednessChangeFromPromotionQuery()) and
  c.getConvertedExpr() = e and
  fromType = c.getFromType() and
  toType = c.getToType() and
  (
    fromType.getSignedness() != toType.getSignedness() and changeType = "signedness"
    or
    fromType.getTypeCategory() != toType.getTypeCategory() and changeType = "type category"
  ) and
  // Ignore crement operations
  not exists(CrementOperation cop | cop.getAnOperand() = e) and
  // Exception 1: allow safe constant conversions
  not (
    e.getValue().toInt() >= 0 and
    fromType.(IntegralType).isSigned() and
    toType.(IntegralType).isUnsigned()
  ) and
  // Exception 2: allow safe conversions from integral to floating-point types
  not (
    e.isConstant() and
    fromType.getTypeCategory() = Integral() and
    toType.getTypeCategory() = FloatingPoint()
  )
select e,
  c.getKindOfConversion() + " from '" + fromType.getName() + "' to '" + toType.getName() +
    "' changes " + changeType + "."
