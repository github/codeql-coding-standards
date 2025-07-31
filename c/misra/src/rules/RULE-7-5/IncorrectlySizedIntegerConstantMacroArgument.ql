/**
 * @id c/misra/incorrectly-sized-integer-constant-macro-argument
 * @name RULE-7-5: The argument of an integer constant macro shall have an appropriate size
 * @description Integer constant macros argument values should be values of a compatible size.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-5
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.IntegerConstantMacro
import codingstandards.cpp.Literals

predicate matchesSign(IntegerConstantMacro macro, PossiblyNegativeLiteral literal) {
  literal.isNegative() implies macro.isSigned()
}

bindingset[literal]
predicate matchesSize(IntegerConstantMacro macro, PossiblyNegativeLiteral literal) {
  literal.getRawValue() <= macro.maxValue() and
  literal.getRawValue() >= macro.minValue()
}

from
  PossiblyNegativeLiteral literal, MacroInvocation invoke, IntegerConstantMacro macro,
  string explanation
where
  not isExcluded(invoke, Types2Package::incorrectlySizedIntegerConstantMacroArgumentQuery()) and
  invoke.getMacro() = macro and
  literal = invoke.getExpr() and
  (
    not matchesSign(macro, literal) and
    explanation = " cannot be negative"
    or
    matchesSign(macro, literal) and
    // Wait for BigInt support to check 64 bit macro types.
    macro.getSize() < 64 and
    not matchesSize(macro, literal) and
    explanation = " is outside of the allowed range " + macro.getRangeString()
  )
select literal, "Value provided to integer constant macro " + macro.getName() + explanation
