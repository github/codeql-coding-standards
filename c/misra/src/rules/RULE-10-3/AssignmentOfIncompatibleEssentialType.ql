/**
 * @id c/misra/assignment-of-incompatible-essential-type
 * @name RULE-10-3: Do not assign to an object with a different essential type category or narrower essential type
 * @description The value of an expression shall not be assigned to an object with a narrower
 *              essential type or of a different essential type category.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-10-3
 *       maintainability
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
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
  ) and
  // Exception 4: Real floating point values may be assignable to complex floating point values
  not (
    lValueTypeCategory = EssentiallyFloatingType(Complex()) and
    rValueTypeCategory = EssentiallyFloatingType(Real()) and
    lValueEssentialType.getSize() >= rValueEssentialType.getSize() * 2
  )
select rValue, message
