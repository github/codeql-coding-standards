/**
 * @id cpp/misra/locale-global-function-not-allowed
 * @name RULE-25-5-1: The setlocale and std::locale::global functions shall not be called
 * @description Calling setlocale or std::locale::global functions can introduce data races with
 *              functions that use the locale, leading to undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-25-5-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       concurrency
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.BannedFunctions

class BannedLocaleFunction extends Function {
  BannedLocaleFunction() {
    this.hasGlobalOrStdName("setlocale") or
    this.hasQualifiedName("std", "locale", "global")
  }
}

from BannedFunctions<BannedLocaleFunction>::Use use
where not isExcluded(use, BannedAPIsPackage::localeGlobalFunctionNotAllowedQuery())
select use, use.getAction() + " banned function '" + use.getFunctionName() + "' from <locale>."
