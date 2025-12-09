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
import codingstandards.cpp.misra.ArithmeticConversions
import codingstandards.cpp.misra.BuiltInTypeRules

from
  Expr e, IntegerPromotionOrUsualArithmeticConversion c,
  MisraCpp23BuiltInTypes::NumericType fromType, MisraCpp23BuiltInTypes::NumericType toType,
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
    fromType.getTypeCategory() = MisraCpp23BuiltInTypes::IntegralTypeCategory() and
    toType.getTypeCategory() = MisraCpp23BuiltInTypes::FloatingPointTypeCategory()
  )
select e,
  c.getKindOfConversion() + " from '" + fromType.getName() + "' to '" + toType.getName() +
    "' changes " + changeType + "."
