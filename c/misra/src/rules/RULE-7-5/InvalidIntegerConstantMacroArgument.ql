/**
 * @id c/misra/invalid-integer-constant-macro-argument
 * @name RULE-7-5: The argument of an integer constant macro shall be a literal
 * @description Integer constant macros should be given a literal value as an argument.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-7-5
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.IntegerConstantMacro
import codingstandards.cpp.Literals
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

predicate containsMacroInvocation(MacroInvocation outer, MacroInvocation inner) {
  outer.getExpr() = inner.getExpr() and
  exists(outer.getUnexpandedArgument(0).indexOf(inner.getMacroName()))
}

from MacroInvocation invoke, IntegerConstantMacro macro
where
  not isExcluded(invoke, Types2Package::invalidIntegerConstantMacroArgumentQuery()) and
  invoke.getMacro() = macro and
  (
    not invoke.getExpr() instanceof PossiblyNegativeLiteral
    or
    containsMacroInvocation(invoke, _)
  )
select invoke.getExpr(),
  "Argument to integer constant macro " + macro.getName() + " must be an integer literal."
