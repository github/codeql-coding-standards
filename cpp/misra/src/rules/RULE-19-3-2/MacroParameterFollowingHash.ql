/**
 * @id cpp/misra/macro-parameter-following-hash
 * @name RULE-19-3-2: A macro parameter immediately following a # operator shall not be immediately followed by a ##
 * @description A macro parameter immediately following a # operator shall not be immediately
 *              followed by a ## operator.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-19-3-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.macroparameterfollowinghash.MacroParameterFollowingHash

class MacroParameterFollowingHashQuery extends MacroParameterFollowingHashSharedQuery {
  MacroParameterFollowingHashQuery() {
    this = ImportMisra23Package::macroParameterFollowingHashQuery()
  }
}
