/**
 * @id c/misra/integer-constant-macro-argument-uses-suffix
 * @name RULE-7-5: The argument of an integer constant macro shall not use literal suffixes u, l, or ul
 * @description Integer constant macros should be used integer literal values with no u/l suffix.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-5
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.IntegerConstantMacro
import codingstandards.cpp.Literals

predicate usesSuffix(MacroInvocation invoke) {
  invoke.getUnexpandedArgument(0).regexpMatch(".*[uUlL]")
}

from MacroInvocation invoke, PossiblyNegativeLiteral argument
where
  not isExcluded(invoke, Types2Package::integerConstantMacroArgumentUsesSuffixQuery()) and
  invoke.getMacro() instanceof IntegerConstantMacro and
  invoke.getExpr() = argument and
  usesSuffix(invoke)
select invoke.getExpr(), "Integer constant macro arguments should not have 'u'/'l' suffix."
