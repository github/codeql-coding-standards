/**
 * @id cpp/misra/avoid-program-terminating-functions
 * @name RULE-18-5-2: Program-terminating functions should not be used
 * @description Using program-terminating functions like abort, exit, _Exit, quick_exit or terminate
 *              causes the stack to not be unwound and object destructors to not be called,
 *              potentially leaving the environment in an undesirable state.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-18-5-2
 *       scope/single-translation-unit
 *       maintainability
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.AlertReporting
import codingstandards.cpp.BannedFunctions

class TerminatingFunction extends Function {
  TerminatingFunction() {
    this.hasQualifiedName(["", "std"], ["abort", "exit", "_Exit", "quick_exit"])
    or
    // std::terminate does not occur in the global namespace.
    this.hasQualifiedName("std", "terminate")
  }
}

predicate isInAssertMacroInvocation(BannedFunctions<TerminatingFunction>::UseExpr use) {
  exists(MacroInvocation mi |
    mi.getMacroName() = "assert" and
    mi.getAnExpandedElement() = use
  )
}

from BannedFunctions<TerminatingFunction>::UseExpr use
where
  not isExcluded(use, BannedAPIsPackage::avoidProgramTerminatingFunctionsQuery()) and
  // Exclude the uses in the assert macro
  not isInAssertMacroInvocation(use)
select use.getPrimaryElement(),
  use.getAction() + " program-terminating function '" + use.getFunctionName() + "'."
