/**
 * @id c/misra/incorrectly-sized-integer-constant-macro-argument
 * @name RULE-7-5: The argument of an integer constant macro shall have an appropriate size
 * @description Integer constant macros argument values should be values of a compatible size.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-5
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.IntegerConstantMacro
import codingstandards.cpp.Literals

predicate matchesSign(IntegerConstantMacro macro, PossiblyNegativeLiteral literal) {
  literal.isNegative() implies macro.isSigned()
}

predicate matchesSize(IntegerConstantMacro macro, PossiblyNegativeLiteral literal) {
  // Wait for BigInt support to check 64 bit macro types.
  (macro.getSize() < 64 and matchesSign(macro, literal))
  implies
  (
    literal.getRawValue() <= macro.maxValue() and
    literal.getRawValue() >= macro.minValue()
  )
}

from
  PossiblyNegativeLiteral literal, MacroInvocation invoke, IntegerConstantMacro macro,
  string explanation
where
  not isExcluded(invoke, Types2Package::incorrectlySizedIntegerConstantMacroArgumentQuery()) and
  invoke.getMacro() = macro and
  literal = invoke.getExpr() and
  (
    not matchesSign(macro, invoke.getExpr()) and explanation = " cannot be negative"
    or
    not matchesSize(macro, invoke.getExpr()) and
    explanation = " is outside of the allowed range " + macro.getRangeString()
  )
select invoke.getExpr(), "Value provided to integer constant macro " + macro.getName() + explanation
