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
import codingstandards.cpp.Macro
import codingstandards.c.Pointers

MacroInvocation getAMacroInvocation(CStyleCast cast) { result.getAnExpandedElement() = cast }

Macro getPrimaryMacro(CStyleCast cast) {
  exists(MacroInvocation mi |
    mi = getAMacroInvocation(cast) and
    not exists(MacroInvocation otherMi |
      otherMi = getAMacroInvocation(cast) and otherMi.getParentInvocation() = mi
    ) and
    result = mi.getMacro() and
    not result instanceof FunctionLikeMacro
  )
}

from Locatable primaryLocation, CStyleCast cast, Type typeFrom, Type typeTo
where
  not isExcluded(cast, Pointers1Package::castBetweenObjectPointerAndDifferentObjectTypeQuery()) and
  typeFrom = cast.getExpr().getUnderlyingType() and
  typeTo = cast.getUnderlyingType() and
  [typeFrom, typeTo] instanceof IntegralType and
  [typeFrom, typeTo] instanceof PointerToObjectType and
  not isNullPointerConstant(cast.getExpr()) and
  // If this alert is arising through a macro expansion, flag the macro instead, to
  // help make the alerts more manageable
  if exists(getPrimaryMacro(cast))
  then primaryLocation = getPrimaryMacro(cast)
  else primaryLocation = cast
select primaryLocation,
  "Cast performed between a pointer to object type and a pointer to an integer type."
