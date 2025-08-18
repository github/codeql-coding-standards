/**
 * @id cpp/misra/banned-system-function
 * @name RULE-21-2-3: The library function system from <cstdlib> shall not be used
 * @description Using the system() function from cstdlib or stdlib.h causes undefined behavior and
 *              potential security vulnerabilities.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-2-3
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       security
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.BannedFunctions

class SystemFunction extends Function {
  SystemFunction() { this.hasGlobalName("system") or this.hasQualifiedName("std", "system") }
}

from Element element, string message
where
  not isExcluded(element, BannedAPIsPackage::bannedSystemFunctionQuery()) and
  (
    element instanceof BannedFunctions<SystemFunction>::Use and
    message =
      element.(BannedFunctions<SystemFunction>::Use).getAction() + " banned function '" +
        element.(BannedFunctions<SystemFunction>::Use).getFunctionName() + "'."
    or
    element instanceof MacroInvocation and
    element.(MacroInvocation).getMacroName() = "system" and
    message = "Use of banned macro 'system'."
  )
select element, message
