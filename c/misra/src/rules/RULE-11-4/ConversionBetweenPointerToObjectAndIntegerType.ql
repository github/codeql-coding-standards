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
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Macro
import codingstandards.cpp.types.Pointers

MacroInvocation getAMacroInvocation(CStyleCast cast) { result.getAnExpandedElement() = cast }

Macro getPrimaryMacro(CStyleCast cast) {
  exists(MacroInvocation mi |
    mi = getAMacroInvocation(cast) and
    not exists(MacroInvocation otherMi |
      otherMi = getAMacroInvocation(cast) and otherMi.getParentInvocation() = mi
    ) and
    result = mi.getMacro()
  )
}

Macro getNonFunctionPrimaryMacro(CStyleCast cast) {
  result = getPrimaryMacro(cast) and
  not result instanceof FunctionLikeMacro
}

from
  Locatable primaryLocation, CStyleCast cast, Type typeFrom, Type typeTo, string message,
  string extraMessage, Locatable optionalPlaceholderLocation, string optionalPlaceholderMessage
where
  not isExcluded(cast, Pointers1Package::conversionBetweenPointerToObjectAndIntegerTypeQuery()) and
  typeFrom = cast.getExpr().getUnderlyingType() and
  typeTo = cast.getUnderlyingType() and
  (
    typeFrom instanceof PointerToObjectType and
    typeTo instanceof IntegralType and
    message =
      "Cast from pointer to object type '" + typeFrom + "' to integer type '" + typeTo + "'" +
        extraMessage + "."
    or
    typeFrom instanceof IntegralType and
    typeTo instanceof PointerToObjectType and
    message =
      "Cast from integer type '" + typeFrom + "' to pointer to object type '" + typeTo + "'" +
        extraMessage + "."
  ) and
  not isNullPointerConstant(cast.getExpr()) and
  // If this alert is arising through a non-function-like macro expansion, flag the macro instead, to
  // help make the alerts more manageable. We only do this for non-function-like macros because they
  // cannot be context specific.
  if exists(getNonFunctionPrimaryMacro(cast))
  then
    primaryLocation = getNonFunctionPrimaryMacro(cast) and
    extraMessage = "" and
    optionalPlaceholderLocation = primaryLocation and
    optionalPlaceholderMessage = ""
  else (
    primaryLocation = cast and
    // If the cast is in a macro expansion which is context specific, we still report the original
    // location, but also add a link to the most specific macro that contains the cast, to aid
    // validation.
    if exists(getPrimaryMacro(cast))
    then
      extraMessage = " from expansion of macro $@" and
      exists(Macro m |
        m = getPrimaryMacro(cast) and
        optionalPlaceholderLocation = m and
        optionalPlaceholderMessage = m.getName()
      )
    else (
      extraMessage = "" and
      optionalPlaceholderLocation = cast and
      optionalPlaceholderMessage = ""
    )
  )
select primaryLocation, message, optionalPlaceholderLocation, optionalPlaceholderMessage
