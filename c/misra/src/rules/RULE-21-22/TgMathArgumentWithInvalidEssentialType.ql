/**
 * @id c/misra/tg-math-argument-with-invalid-essential-type
 * @name RULE-21-22: All operand arguments to type-generic macros in <tgmath.h> shall have an appropriate essential type
 * @description All operand arguments to any type-generic macros in <tgmath.h> shall have an
 *              appropriate essential type.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-21-22
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.TgMath
import codingstandards.c.misra.EssentialTypes

EssentialTypeCategory getAnAllowedEssentialTypeCategory(TgMathInvocation call) {
  result = EssentiallySignedType()
  or
  result = EssentiallyUnsignedType()
  or
  result = EssentiallyFloatingType(Real())
  or
  call.allowsComplex() and
  result = EssentiallyFloatingType(Complex())
}

string getAllowedTypesString(TgMathInvocation call) {
  if call.allowsComplex()
  then result = "essentially signed, unsigned, or floating type"
  else result = "essentially signed, unsigned, or real floating type"
}

from
  TgMathInvocation call, Expr convertedArg, Expr unconverted, int argIndex, Type type,
  EssentialTypeCategory category
where
  not isExcluded(call, EssentialTypes2Package::tgMathArgumentWithInvalidEssentialTypeQuery()) and
  // We must handle conversions specially, as clang inserts casts in the macro body we want to ignore.
  convertedArg = call.getExplicitlyConvertedOperandArgument(argIndex) and
  unconverted = convertedArg.getUnconverted() and
  // Do not use `convertedArg.getEssentialType()`, as that is affected by clang's casts in the macro body.
  type = getEssentialTypeBeforeConversions(convertedArg) and
  category = getEssentialTypeCategory(type) and
  not category = getAnAllowedEssentialTypeCategory(call)
select unconverted,
  "Argument " + (argIndex + 1) + " provided to type-generic macro '" + call.getMacroName() +
    "' has " + category.toString().toLowerCase() + ", which is not " + getAllowedTypesString(call) +
    "."
