import cpp
import BuiltInTypeRules

/**
 * An expression that represents a integral promotion or usual arithmetic conversion.
 *
 * Such conversions are usual either explicitly described with a `Cast`, or, in the case
 * of assign operations, implicitly applied to an lvalue.
 */
abstract class IntegerPromotionOrUsualArithmeticConversion extends Expr {
  abstract MisraCpp23BuiltInTypes::NumericType getFromType();

  abstract MisraCpp23BuiltInTypes::NumericType getToType();

  abstract Expr getConvertedExpr();

  abstract string getKindOfConversion();
}

/**
 * A `Cast` which is either an integer promotion or usual arithmetic conversion.
 */
abstract class IntegerPromotionOrUsualArithmeticConversionAsCast extends IntegerPromotionOrUsualArithmeticConversion,
  Cast
{
  MisraCpp23BuiltInTypes::NumericType fromType;
  MisraCpp23BuiltInTypes::NumericType toType;

  IntegerPromotionOrUsualArithmeticConversionAsCast() {
    fromType = this.getExpr().getType() and
    toType = this.getType() and
    this.isImplicit()
  }

  override MisraCpp23BuiltInTypes::NumericType getFromType() { result = fromType }

  override MisraCpp23BuiltInTypes::NumericType getToType() { result = toType }

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
    fromType.getBuiltInSize() < sizeOfInt() and
    // To type is bigger than or equal to int
    toType.getBuiltInSize() >= sizeOfInt() and
    // An integer promotion is a conversion from an integral type to an integral type
    //
    // This deliberately excludes integer promotions from `bool` and unscoped enums which do not
    // have a fixed underlying type, because neither of these are considered integral types in the
    // MISRA C++ rules.
    fromType.getTypeCategory() = MisraCpp23BuiltInTypes::IntegralTypeCategory() and
    toType.getTypeCategory() = MisraCpp23BuiltInTypes::IntegralTypeCategory()
  }

  override string getKindOfConversion() { result = "Integer promotion" }
}

class ImpliedUsualArithmeticConversion extends IntegerPromotionOrUsualArithmeticConversion {
  MisraCpp23BuiltInTypes::NumericType fromType;
  MisraCpp23BuiltInTypes::NumericType toType;

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
      not fromType.isSameType(toType)
    )
  }

  override MisraCpp23BuiltInTypes::NumericType getFromType() { result = fromType }

  override MisraCpp23BuiltInTypes::NumericType getToType() { result = toType }

  override Expr getConvertedExpr() { result = this }

  override string getKindOfConversion() { result = "Usual arithmetic conversion" }
}

class ImpliedIntegerPromotion extends IntegerPromotionOrUsualArithmeticConversion {
  MisraCpp23BuiltInTypes::NumericType fromType;

  ImpliedIntegerPromotion() {
    (
      exists(AssignLShiftExpr aop | aop.getLValue() = this) or
      exists(AssignRShiftExpr aop | aop.getLValue() = this)
    ) and
    // The rule applies to integer promotions from and to MISRA C++ numeric types
    // However, you cannot have an integer promotion on a float, so we restrict
    // this to integral types only
    fromType = this.getType() and
    fromType.getTypeCategory() = MisraCpp23BuiltInTypes::IntegralTypeCategory() and
    // If the size is less than int, then it is an implied integer promotion
    fromType.getBuiltInSize() < sizeOfInt()
  }

  override MisraCpp23BuiltInTypes::NumericType getFromType() { result = fromType }

  override MisraCpp23BuiltInTypes::CanonicalIntegerNumericType getToType() {
    // Only report the canonical type - e.g. `int` not `signed int`
    if result instanceof Char16Type or result instanceof Char32Type or result instanceof Wchar_t
    then
      // Smallest type that can hold the value of the `fromType`
      result =
        min(MisraCpp23BuiltInTypes::NumericType candidateType |
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
        fromType.getSignedness() = MisraCpp23BuiltInTypes::Signed()
        or
        // If the `fromType` is unsigned, but the result can fit into the signed int type, then the
        // result must be signed as well.
        fromType.getIntegralUpperBound() <=
          any(IntType t | t.isSigned())
              .(MisraCpp23BuiltInTypes::NumericType)
              .getIntegralUpperBound()
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
