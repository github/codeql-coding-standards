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

string argumentSuffix(MacroInvocation invoke) {
  result = invoke.getUnexpandedArgument(0).regexpCapture(".*[^uUlL]([uUlL]+)$", 1)
}

from MacroInvocation invoke, PossiblyNegativeLiteral argument, string suffix
where
  not isExcluded(invoke, Types2Package::integerConstantMacroArgumentUsesSuffixQuery()) and
  invoke.getMacro() instanceof IntegerConstantMacro and
  invoke.getExpr() = argument and
  suffix = argumentSuffix(invoke)
select invoke.getExpr(),
  "Value suffix '" + suffix + "' is not allowed on provided argument to integer constant macro " +
    invoke.getMacroName() + "."
