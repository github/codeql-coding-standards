/**
 * @id c/misra/invalid-define-or-undef-of-std-bool-macro
 * @name RULE-1-5: Programs may not undefine or redefine the macros bool, true, or false
 * @description Directives that undefine and/or redefine the standard boolean macros has been
 *              declared an obsolescent language feature since C99.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-1-5
 *       maintainability
 *       readability
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

string getABoolMacroName() { result = ["true", "false", "bool"] }

from PreprocessorDirective directive, string opString, string macroName
where
  not isExcluded(directive, Language4Package::invalidDefineOrUndefOfStdBoolMacroQuery()) and
  macroName = getABoolMacroName() and
  (
    macroName = directive.(Macro).getName() and
    opString = "define"
    or
    macroName = directive.(PreprocessorUndef).getName() and
    opString = "undefine"
  )
select directive, "Invalid " + opString + " of boolean standard macro '" + macroName + "'."
