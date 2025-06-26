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
 * A `Conversion` that is relevant for the rule.
 */
abstract class RelevantConversion extends Conversion {
  NumericType fromType;
  NumericType toType;

  RelevantConversion() {
    fromType = this.getExpr().getType().getUnspecifiedType() and
    toType = this.getType().getUnspecifiedType() and
    this.isImplicit()
  }

  Type getFromType() { result = fromType }

  Type getToType() { result = toType }
}

class UsualArithmeticConversion extends RelevantConversion {
  UsualArithmeticConversion() {
    (
      exists(BinaryOperation op | op.getAnOperand().getFullyConverted() = this) or
      exists(UnaryOperation uao | uao.getOperand().getFullyConverted() = this) or
      exists(AssignArithmeticOperation ao | ao.getAnOperand().getFullyConverted() = this)
    )
  }
}

class IntegerPromotion extends RelevantConversion {
  IntegerPromotion() {
    // Only consider cases where the integer promotion is the last conversion applied
    exists(Expr e | e.getFullyConverted() = this) and
    // Integer promotion occurs where the from type is smaller than int
    fromType.getRealSize() < any(IntType i).(NumericType).getRealSize() and
    // To type is bigger than or equal to int
    toType.getRealSize() >= any(IntType i).(NumericType).getRealSize() and
    fromType.getTypeCategory() = Integral() and
    toType.getTypeCategory() = Integral()
  }
}

from Expr e, RelevantConversion c, NumericType fromType, NumericType toType, string changeType
where
  not isExcluded(e, ConversionsPackage::noSignednessChangeFromPromotionQuery()) and
  c = e.getConversion() and
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
  "Conversion from '" + fromType.getName() + "' to '" + toType.getName() + "' changes " + changeType
    + "."
