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

/**
 * If the range of values can be represented as a signed int, it is promoted to signed int.
 *
 * A value may also promote to unsigned int but only if `int` cannot represent the range of
 * values. Which basically means only an `unsigned int` promotes to `unsigned int`, so we don't
 * need to do anything in this case.
 *
 * An unsigned int bitfield with fewer than 32 bits is promoted to `int`.
 */
predicate promotesToSignedInt(Expr e) {
  exists(int intBits, int intBytes |
    intBytes = any(IntType t).getSize() and
    intBits = intBytes * 8 and
    (
      e.(FieldAccess).getTarget().(BitField).getNumBits() < intBits
      or
      e.getUnderlyingType().(IntegralType).getSize() < intBytes
    )
  )
}

Type getPromotedType(Expr e) {
  if promotesToSignedInt(e) then result.(IntType).isSigned() else result = e.getUnderlyingType()
}

Type canonicalize(Type type) {
  if type instanceof IntegralType
  then result = type.(IntegralType).getCanonicalArithmeticType()
  else result = type
}

Type getEffectiveStandardType(Expr e) { result = canonicalize(getPromotedType(e)) }

from TgMathInvocation call, Type firstType
where
  not isExcluded(call, EssentialTypes2Package::tgMathArgumentsWithDifferingStandardTypeQuery()) and
  firstType = getEffectiveStandardType(call.getExplicitlyConvertedOperandArgument(0)) and
  not forall(Expr arg | arg = call.getExplicitlyConvertedOperandArgument(_) |
    firstType = getEffectiveStandardType(arg)
  )
select call,
  "Call to type-generic macro '" + call.getMacroName() +
    "' has arguments with differing standard types (" +
    argTypesString(call, call.getNumberOfOperandArguments() - 1) + ")."
