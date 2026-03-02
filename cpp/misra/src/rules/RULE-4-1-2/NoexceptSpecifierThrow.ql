/**
 * @id cpp/misra/noexcept-specifier-throw
 * @name RULE-4-1-2: The noexcept specifier throw() is a deprecated language feature should not be used
 * @description Deprecated language features such as the noexcept specifier throw() are only
 *              supported for backwards compatibility; these are considered bad practice, or have
 *              been superceded by better alternatives.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-4-1-2
 *       scope/single-translation-unit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from Function f
where
  not isExcluded(f, Toolchain3Package::noexceptSpecifierThrowQuery()) and
  f.isNoThrow() and
  not f.isCompilerGenerated()
select f,
  "Function '" + f.getName() + "' is declared with the deprecated noexcept specifier 'throw()'."
