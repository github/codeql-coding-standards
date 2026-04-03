/**
 * @id cpp/misra/unused-limited-visibility-function
 * @name RULE-0-2-4: Functions with limited visibility should be used at least once
 * @description Unused functions may indicate a coding error or require maintenance; functions that
 *              are unused with certain visibility have no effect on the program and should be
 *              removed.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-0-2-4
 *       scope/system
 *       maintainability
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.unusedlocalfunction.UnusedLocalFunction

module UnusedLimitedVisibilityFunctionConfig implements UnusedLocalFunctionConfigSig {
  Query getQuery() { result = DeadCode10Package::unusedLimitedVisibilityFunctionQuery() }
}

import UnusedLocalFunction<UnusedLimitedVisibilityFunctionConfig>
