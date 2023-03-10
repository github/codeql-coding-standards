/**
 * @id c/misra/termination-macros-of-stdlibh-used
 * @name RULE-21-8: The Standard Library termination macros of 'stdlib.h' shall not be used
 * @description The use of the Standard Library macros 'abort', 'exit' and 'system' of 'stdlib.h'
 *              may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-21-8
 *       correctness
 *       security
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

class BannedMacro extends Macro {
  BannedMacro() { this.getName().toLowerCase() = ["abort", "exit", "system"] }
}

from MacroInvocation mi, BannedMacro m
where
  not isExcluded(mi, BannedPackage::terminationMacrosOfStdlibhUsedQuery()) and
  m.getAnInvocation() = mi
select mi, "Use of banned macro " + m.getName() + "."
