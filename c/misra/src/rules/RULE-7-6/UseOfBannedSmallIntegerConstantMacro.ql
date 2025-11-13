/**
 * @id c/misra/use-of-banned-small-integer-constant-macro
 * @name RULE-7-6: The small integer variants of the minimum-width integer constant macros shall not be used
 * @description Small integer constant macros expression are promoted to type int, which can lead to
 *              unexpected results.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-7-6
 *       readability
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.IntegerConstantMacro

from MacroInvocation macroInvoke, IntegerConstantMacro macro
where
  not isExcluded(macroInvoke, Types2Package::useOfBannedSmallIntegerConstantMacroQuery()) and
  macroInvoke.getMacro() = macro and
  macro.isSmall()
select macroInvoke, "Usage of small integer constant macro " + macro.getName() + " is not allowed."
