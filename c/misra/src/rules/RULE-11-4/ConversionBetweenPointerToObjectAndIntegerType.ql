/**
 * @id c/misra/conversion-between-pointer-to-object-and-integer-type
 * @name RULE-11-4: A conversion should not be performed between a pointer to object and an integer type
 * @description Converting between a pointer to an object and an integer type may result in
 *              undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-4
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Pointers

from CStyleCast cast, Type typeFrom, Type typeTo
where
  not isExcluded(cast, Pointers1Package::conversionBetweenPointerToObjectAndIntegerTypeQuery()) and
  typeFrom = cast.getExpr().getUnderlyingType() and
  typeTo = cast.getUnderlyingType() and
  [typeFrom, typeTo] instanceof IntegralType and
  [typeFrom, typeTo] instanceof PointerToObjectType and
  not isNullPointerConstant(cast.getExpr())
select cast, "Cast performed between a pointer to object type and a pointer to an integer type."
