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

from MacroInvocation mi
where
  not isExcluded(mi, BannedFunctionsPackage::macroOffsetofUsedQuery()) and
  mi.getMacroName() = "offsetof"
select mi, "Use of banned macro " + mi.getMacroName() + "."
