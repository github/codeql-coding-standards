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

predicate isAssertMacroCall(FunctionCall call) {
  exists(MacroInvocation mi |
    mi.getMacroName() = "assert" and
    mi.getAnExpandedElement() = call
  )
}

from Expr e, Function f, string functionName, string action
where
  not isExcluded(e, BannedAPIsPackage::avoidProgramTerminatingFunctionsQuery()) and
  isTerminatingFunction(f, functionName) and
  (
    // Direct function calls (excluding assert macro calls)
    e instanceof FunctionCall and
    f = e.(FunctionCall).getTarget() and
    not isAssertMacroCall(e) and
    action = "Call to"
    or
    // Function access
    e instanceof FunctionAccess and
    f = e.(FunctionAccess).getTarget() and
    action = "Address taken for"
  )
select e, action + " program-terminating function '" + functionName + "'."
