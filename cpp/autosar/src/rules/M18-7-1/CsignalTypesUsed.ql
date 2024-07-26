/**
 * @id cpp/autosar/csignal-types-used
 * @name M18-7-1: The signal-handling types of <csignal> shall not be used
 * @description Signal handling contains implementation-defined and undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m18-7-1
 *       maintainability
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.csignaltypesused.CsignalTypesUsed

class CsignalTypesUsedQuery extends CsignalTypesUsedSharedQuery {
  CsignalTypesUsedQuery() { this = BannedLibrariesPackage::csignalTypesUsedQuery() }
}
