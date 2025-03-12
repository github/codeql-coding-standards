/**
 * @id c/misra/tg-math-arguments-with-differing-standard-type
 * @name RULE-21-23: Operand arguments for an invocation of a type-generic macro shall have the same standard type
 * @description All operand arguments to any multi-argument type-generic macros in <tgmath.h> shall
 *              have the same standard type.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-21-23
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.TgMath

Expr getFullyExplicitlyConverted(Expr e) {
  if e.hasExplicitConversion()
  then result = getFullyExplicitlyConverted(e.getExplicitlyConverted())
  else result = e
}

string argTypesString(TgMathInvocation call, int i) {
  exists(string typeStr |
    typeStr = getEffectiveStandardType(call.getOperandArgument(i)).toString() and
    (
      i = 0 and result = typeStr
      or
      i > 0 and result = argTypesString(call, i - 1) + ", " + typeStr
    )
  )
}

predicate promotes(Type type) { type.(IntegralType).getSize() < any(IntType t).getSize() }

Type integerPromote(Type type) {
  promotes(type) and result.(IntType).isSigned()
  or
  not promotes(type) and result = type
}

Type canonicalize(Type type) {
  if type instanceof IntegralType
  then result = type.(IntegralType).getCanonicalArithmeticType()
  else result = type
}

Type getEffectiveStandardType(Expr e) {
  result =
    canonicalize(integerPromote(getFullyExplicitlyConverted(e).getType().stripTopLevelSpecifiers()))
}

from TgMathInvocation call, Type firstType
where
  not isExcluded(call, EssentialTypes2Package::tgMathArgumentsWithDifferingStandardTypeQuery()) and
  firstType = getEffectiveStandardType(call.getAnOperandArgument()) and
  not forall(Expr arg | arg = call.getAnOperandArgument() |
    firstType = getEffectiveStandardType(arg)
  )
select call,
  "Call to type-generic macro '" + call.getMacroName() +
    "' has arguments with differing standard types (" +
    argTypesString(call, call.getNumberOfOperandArguments() - 1) + ")."
