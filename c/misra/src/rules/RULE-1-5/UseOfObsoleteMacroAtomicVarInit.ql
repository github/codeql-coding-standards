/**
 * @id c/misra/use-of-obsolete-macro-atomic-var-init
 * @name RULE-1-5: Disallowed usage of obsolete macro ATOMIC_VAR_INIT compiled as C18
 * @description The macro ATOMIC_VAR_INIT is has been declared an obsolescent language feature since
 *              C18.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-1-5
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from MacroInvocation invoke, Compilation c, string flag
where
  not isExcluded(invoke, Language4Package::useOfObsoleteMacroAtomicVarInitQuery()) and
  invoke.getMacroName() = "ATOMIC_VAR_INIT" and
  flag = c.getAnArgument() and
  flag.regexpMatch("-std=c1[78]")
select invoke,
  "Usage of macro ATOMIC_VAR_INIT() is considered obsolete for c version '" + flag + "'."
