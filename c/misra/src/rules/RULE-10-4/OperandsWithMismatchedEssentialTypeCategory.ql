/**
 * @id c/misra/operands-with-mismatched-essential-type-category
 * @name RULE-10-4: Operator with usual arithmetic conversions shall have operands with the same essential type category
 * @description Both operands of an operator in which the usual arithmetic conversions are performed
 *              shall have the same essential type category.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-10-4
 *       maintainability
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes
import codingstandards.c.misra.MisraExpressions

from
  OperationWithUsualArithmeticConversions op, Type leftOpEssentialType, Type rightOpEssentialType,
  EssentialTypeCategory leftOpTypeCategory, EssentialTypeCategory rightOpTypeCategory,
  string message
where
  not isExcluded(op, EssentialTypesPackage::operandsWithMismatchedEssentialTypeCategoryQuery()) and
  leftOpEssentialType = getEssentialType(op.getLeftOperand()) and
  rightOpEssentialType = getEssentialType(op.getRightOperand()) and
  leftOpTypeCategory = getEssentialTypeCategory(leftOpEssentialType) and
  rightOpTypeCategory = getEssentialTypeCategory(rightOpEssentialType) and
  (
    not leftOpTypeCategory = rightOpTypeCategory and
    message =
      "The operands of this operator with usual arithmetic conversions have mismatched essential types (left operand: "
        + leftOpTypeCategory + ", right operand: " + rightOpTypeCategory + ")."
    or
    // This is not technically covered by the rule, but the examples make it clear that this should
    // be reported as non-compliant.
    leftOpTypeCategory = EssentiallyEnumType() and
    rightOpTypeCategory = EssentiallyEnumType() and
    not leftOpEssentialType = rightOpEssentialType and
    message =
      "The operands of this operator with usual arithmetic conversions have mismatched essentially Enum types (left operand: "
        + leftOpEssentialType + ", right operand: " + rightOpEssentialType + ")."
  ) and
  not (
    // Mismatch is permitted if using "+" or "+=" with one character operand and one integer operand
    op.getOperator() = ["+", "+="] and
    [leftOpTypeCategory, rightOpTypeCategory] = EssentiallyCharacterType() and
    [leftOpTypeCategory, rightOpTypeCategory] =
      [EssentiallyUnsignedType().(TEssentialTypeCategory), EssentiallySignedType()]
  ) and
  not (
    // Mismatch is permitted if using "+" or "+=" with one pointer operand and one integer operand
    op.getOperator() = ["-", "-="] and
    leftOpTypeCategory = EssentiallyCharacterType() and
    rightOpTypeCategory =
      [EssentiallyUnsignedType().(TEssentialTypeCategory), EssentiallySignedType()]
  )
select op, message
