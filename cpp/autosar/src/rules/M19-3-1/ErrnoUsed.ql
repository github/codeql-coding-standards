/**
 * @id cpp/autosar/errno-used
 * @name M19-3-1: The error indicator errno shall not be used
 * @description errno is a facility of C++, which should, in theory, be useful, but which, in
 *              practice, is poorly defined by ISO/IEC 14882:2003 [1]. A non-zero value may or may
 *              not indicate that a problem has occurred; therefore, errno shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m19-3-1
 *       correctness
 *       maintainability
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from MacroInvocation mi
where not isExcluded(mi, BannedLibrariesPackage::errnoUsedQuery()) and mi.getMacroName() = "errno"
select mi, "Use of 'errno'."
