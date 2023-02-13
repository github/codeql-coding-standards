/**
 * @id c/misra/inappropriate-essential-type-cast
 * @name RULE-10-5: The value of an expression should not be cast to an inappropriate essential type
 * @description
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-5
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes
import codingstandards.c.misra.MisraExpressions

predicate isIncompatibleEssentialTypeCast(EssentialTypeCategory fromCat, EssentialTypeCategory toCat) {
  fromCat = EssentiallyBooleanType() and
  toCat =
    [
      EssentiallyCharacterType(), EssentiallyEnumType(), EssentiallySignedType(),
      EssentiallyUnsignedType(), EssentiallyFloatingType().(TEssentialTypeCategory)
    ]
  or
  fromCat = EssentiallyCharacterType() and
  toCat =
    [
      EssentiallyBooleanType(), EssentiallyEnumType(),
      EssentiallyFloatingType().(TEssentialTypeCategory)
    ]
  or
  fromCat = EssentiallyEnumType() and
  toCat = [EssentiallyBooleanType(), EssentiallyEnumType().(TEssentialTypeCategory)] // NOTE only if different enum types
  or
  fromCat = EssentiallySignedType() and
  toCat = [EssentiallyBooleanType(), EssentiallyEnumType().(TEssentialTypeCategory)]
  or
  fromCat = EssentiallyUnsignedType() and
  toCat = [EssentiallyBooleanType(), EssentiallyEnumType().(TEssentialTypeCategory)]
  or
  fromCat = EssentiallyFloatingType() and
  toCat =
    [
      EssentiallyBooleanType(), EssentiallyCharacterType(),
      EssentiallyEnumType().(TEssentialTypeCategory)
    ]
}

from
  Cast c, Type essentialFromType, Type essentialToType, EssentialTypeCategory fromCategory,
  EssentialTypeCategory toCategory, string message
where
  not isExcluded(c, EssentialTypesPackage::inappropriateEssentialTypeCastQuery()) and
  not c.isImplicit() and
  essentialFromType = getEssentialTypeBeforeConversions(c.getExpr()) and
  essentialToType = c.getType() and
  fromCategory = getEssentialTypeCategory(essentialFromType) and
  toCategory = getEssentialTypeCategory(essentialToType) and
  isIncompatibleEssentialTypeCast(fromCategory, toCategory) and
  (
    if fromCategory = EssentiallyEnumType() and toCategory = EssentiallyEnumType()
    then
      // If from/to enum types, then only report if the essential types are different
      not essentialToType = essentialFromType and
      message = "Incompatible cast from " + essentialFromType + " to " + essentialToType + "."
    else message = "Incompatible cast from " + fromCategory + " to " + toCategory + "."
  ) and
  not (
    // Exception - casting from `0` or `1` to a boolean type is permitted
    (fromCategory = EssentiallySignedType() or fromCategory = EssentiallyUnsignedType()) and
    toCategory = EssentiallyBooleanType() and
    c.getExpr().getValue().toInt() = [0, 1]
  )
select c, message
