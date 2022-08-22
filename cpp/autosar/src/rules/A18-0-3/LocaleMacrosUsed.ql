/**
 * @id cpp/autosar/locale-macros-used
 * @name A18-0-3: The library <clocale> (locale.h) macros shall not be used
 * @description The locale library, which defines the macros LC_ALL, LC_COLLATE, LC_CTYPE,
 *              LC_MONETARY, LC_NUMERIC, and LC_TIME, shall not be used as it may introduce data
 *              races.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a18-0-3
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from MacroInvocation mi
where
  not isExcluded(mi, BannedLibrariesPackage::localeMacrosUsedQuery()) and
  mi.getMacroName() in ["LC_ALL", "LC_COLLATE", "LC_CTYPE", "LC_MONETARY", "LC_NUMERIC", "LC_TIME"]
select mi, "Use of <clocale> macro '" + mi.getMacroName() + "'."
