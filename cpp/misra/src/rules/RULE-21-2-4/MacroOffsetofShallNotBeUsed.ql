/**
 * @id cpp/misra/macro-offsetof-shall-not-be-used
 * @name RULE-21-2-4: The macro offsetof shall not be used
 * @description The macro offsetof shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-2-4
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.macrooffsetofused.MacroOffsetofUsed

class MacroOffsetofShallNotBeUsedQuery extends MacroOffsetofUsedSharedQuery {
  MacroOffsetofShallNotBeUsedQuery() {
    this = ImportMisra23Package::macroOffsetofShallNotBeUsedQuery()
  }
}
