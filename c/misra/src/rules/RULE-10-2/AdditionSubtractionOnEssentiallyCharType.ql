/**
 * @id c/misra/addition-subtraction-on-essentially-char-type
 * @name RULE-10-2: Inappropriate use of essentially character type operands in addition and subtraction operations
 * @description Expressions of essentially character type shall not be used inappropriately in
 *              addition and subtraction operations.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-2
 *       maintainability
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes

from BinaryArithmeticOperation addOrSub
where
  not isExcluded(addOrSub, EssentialTypesPackage::additionSubtractionOnEssentiallyCharTypeQuery()) and
  addOrSub.getOperator() = ["+", "-"] and
  // At least one operand is essentially character type
  (
    getEssentialTypeCategory(getEssentialType(addOrSub.getLeftOperand())) =
      EssentiallyCharacterType() or
    getEssentialTypeCategory(getEssentialType(addOrSub.getRightOperand())) =
      EssentiallyCharacterType()
  ) and
  not (
    // But the overall essential type is not essentially character type
    getEssentialTypeCategory(getEssentialType(addOrSub)) = EssentiallyCharacterType()
    or
    // Or this is a subtration of one character with another, which is permitted, but produces an integral type
    getEssentialTypeCategory(getEssentialType(addOrSub.getLeftOperand())) =
      EssentiallyCharacterType() and
    getEssentialTypeCategory(getEssentialType(addOrSub.getRightOperand())) =
      EssentiallyCharacterType() and
    addOrSub instanceof SubExpr
  )
select addOrSub,
  "Expressions of essentially character type shall not be used inappropriately in addition and subtraction operations"
