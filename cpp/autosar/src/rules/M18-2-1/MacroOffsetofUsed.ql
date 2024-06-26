/**
 * @id cpp/autosar/macro-offsetof-used
 * @name M18-2-1: The macro offsetof shall not be used
 * @description The macro offsetof shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m18-2-1
 *       security
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.macrooffsetofused_shared.MacroOffsetofUsed_shared

class MacroOffsetofUsedQuery extends MacroOffsetofUsed_sharedSharedQuery {
  MacroOffsetofUsedQuery() { this = BannedFunctionsPackage::macroOffsetofUsedQuery() }
}
