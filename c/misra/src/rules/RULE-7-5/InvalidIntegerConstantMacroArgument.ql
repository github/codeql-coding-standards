/**
 * @id c/misra/invalid-integer-constant-macro-argument
 * @name RULE-7-5: The argument of an integer constant macro shall be a literal
 * @description Integer constant macros should be given a literal value as an argument
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
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

/**
 * The max negative 64 bit signed integer is one less than the negative of the
 * max positive signed 64 bit integer. The only way to create a "negative"
 * literal is to use unary- negation of a positive literal. Therefore, clang
 * (and likely other compilers) rejects `INT64_C(-92233...808)` but accepts
 * `INT64_C(-92233...807 - 1)`. Therefore, in this case allow non-literal
 * expressions.
 */
predicate specialMaxNegative64Exception(IntegerConstantMacro macro, Expr expr) {
  macro.getSize() = 64 and
  macro.isSigned() and
  // Set a cutoff with precision, fix once BigInt library is available.
  upperBound(expr) < macro.minValue() * 0.999999999 and
  upperBound(expr) > macro.minValue() * 1.000000001
}

from MacroInvocation invoke, IntegerConstantMacro macro
where
  not isExcluded(invoke, Types2Package::invalidIntegerConstantMacroArgumentQuery()) and
  invoke.getMacro() = macro and
  not invoke.getExpr() instanceof PossiblyNegativeLiteral and
  not specialMaxNegative64Exception(macro, invoke.getExpr())
select invoke.getExpr(), "Integer constant macro argument must be an integer literal."
