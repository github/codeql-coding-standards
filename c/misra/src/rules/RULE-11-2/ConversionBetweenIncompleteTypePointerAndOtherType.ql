/**
 * @id c/misra/conversion-between-incomplete-type-pointer-and-other-type
 * @name RULE-11-2: Conversions shall not be performed between a pointer to an incomplete type and any other type
 * @description Converting between a pointer to an incomplete type to another type can result in
 *              undefined behaviour or violate encapsulation.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-2
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Pointers
import codingstandards.cpp.Type

from Cast cast, Type type, Type newType
where
  not isExcluded(cast, Pointers1Package::conversionBetweenIncompleteTypePointerAndOtherTypeQuery()) and
  cast.getExpr().getUnderlyingType() = type and
  cast.getType().getUnderlyingType() = newType and
  type != newType and
  // exception: conversion to void type
  not newType instanceof VoidType and
  // exception: conversion from null pointer constant
  not isCastNullPointerConstant(cast) and
  // verify that at least one of the types are incomplete
  (
    type.(PointerType).getBaseType() instanceof IncompleteType or
    newType.(PointerType).getBaseType() instanceof IncompleteType
  )
select cast, "Cast performed between a pointer to incomplete type and another type."
