/**
 * @id c/misra/assignment-of-incompatible-essential-type
 * @name RULE-10-3: The value of an expression shall not be assigned to an object with a narrower essential type or of a
 * @description The value of an expression shall not be assigned to an object with a narrower
 *              essential type or of a different essential type category
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-10-3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes
import codingstandards.c.misra.MisraExpressions

from
  Type lValueType, Expr rValue, Type lValueEssentialType, EssentialTypeCategory lValueTypeCategory,
  Type rValueEssentialType, EssentialTypeCategory rValueTypeCategory, string message
where
  not isExcluded(rValue, EssentialTypesPackage::assignmentOfIncompatibleEssentialTypeQuery()) and
  isAssignmentToEssentialType(lValueType, rValue) and
  lValueEssentialType = lValueType and
  lValueTypeCategory = getEssentialTypeCategory(lValueEssentialType) and
  rValueEssentialType = getEssentialType(rValue) and
  rValueTypeCategory = getEssentialTypeCategory(rValueEssentialType) and
  (
    not lValueTypeCategory = rValueTypeCategory and
    message =
      "Assignment of " + rValueTypeCategory + " value to an object of " + lValueTypeCategory + "."
    or
    lValueTypeCategory = rValueTypeCategory and
    lValueEssentialType.getSize() < rValueEssentialType.getSize() and
    message =
      "Assignment of value of " + lValueTypeCategory + " of size " + rValueEssentialType.getSize() +
        " bytes to an object narrower essential type of size " + lValueEssentialType.getSize() +
        " bytes."
  ) and
  // Exception 1: Constant signed integers can be assigned to unsigned integers in certain cases
  not exists(int const |
    const = rValue.getValue().toInt() and
    rValueTypeCategory = EssentiallySignedType() and
    rValueEssentialType.getSize() <= any(IntType t | t.isSigned()).getSize() and
    lValueTypeCategory = EssentiallyUnsignedType() and
    const >= 0 and
    const <= 2.pow(lValueEssentialType.getSize() * 8)
  )
select rValue, message
