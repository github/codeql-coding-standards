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
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.AlertReporting

predicate isTerminatingFunction(Function f, string functionName) {
  functionName = f.getName() and
  (
    functionName in ["abort", "exit", "_Exit", "quick_exit"] and
    (f.hasQualifiedName("", functionName) or f.hasQualifiedName("std", functionName))
    or
    // std::terminate does not occur in the global namespace.
    functionName = "terminate" and f.hasQualifiedName("std", functionName)
  )
}

class TerminatingFunctionUse extends Expr {
  string action;
  string functionName;

  TerminatingFunctionUse() {
    exists(Function f | isTerminatingFunction(f, functionName) |
      this.(FunctionCall).getTarget() = f and
      action = "Call to"
      or
      this.(FunctionAccess).getTarget() = f and
      action = "Address taken for"
    )
  }

  string getFunctionName() { result = functionName }

  string getAction() { result = action }

  Element getPrimaryElement() {
    // If this is defined in a macro in the users source location, then report the macro
    // expansion, otherwise report the element itself. This ensures that we always report
    // the use of the terminating function, but combine usages when the macro is defined
    // by the user.
    exists(Element e | e = MacroUnwrapper<TerminatingFunctionUse>::unwrapElement(this) |
      if exists(e.getFile().getRelativePath()) then result = e else result = this
    )
  }
}

predicate isInAssertMacroInvocation(TerminatingFunctionUse use) {
  exists(MacroInvocation mi |
    mi.getMacroName() = "assert" and
    mi.getAnExpandedElement() = use
  )
}

from TerminatingFunctionUse use
where
  not isExcluded(use, BannedAPIsPackage::avoidProgramTerminatingFunctionsQuery()) and
  // Exclude the uses in the assert macro
  not isInAssertMacroInvocation(use)
select use.getPrimaryElement(),
  use.getAction() + " program-terminating function '" + use.getFunctionName() + "'."
