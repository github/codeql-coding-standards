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

abstract class RelevantConversion extends Expr {
  abstract Type getFromType();

  abstract Type getToType();

  abstract Expr getConvertedExpr();

  abstract string getKindOfConversion();
}

/**
 * A `Conversion` that is relevant for the rule.
 */
abstract class RelevantRealConversion extends RelevantConversion, Conversion {
  NumericType fromType;
  NumericType toType;

  RelevantRealConversion() {
    fromType = this.getExpr().getType() and
    toType = this.getType() and
    this.isImplicit()
  }

  override Type getFromType() { result = fromType }

  override Type getToType() { result = toType }

  override Expr getConvertedExpr() { result = this.getExpr() }
}

class UsualArithmeticConversion extends RelevantRealConversion {
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

class IntegerPromotion extends RelevantRealConversion {
  IntegerPromotion() {
    // Exclude integer promotions combined with usual arithmetic conversions, which are handled separately
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

from Expr e, RelevantConversion c, NumericType fromType, NumericType toType, string changeType
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
