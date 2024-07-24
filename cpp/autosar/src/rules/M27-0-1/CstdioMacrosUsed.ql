/**
 * @id cpp/autosar/cstdio-macros-used
 * @name M27-0-1: The stream input/output library <cstdio> macros shall not be used
 * @description Streams and file I/O have a large number of unspecified, undefined, and
 *              implementation-defined behaviours associated with them.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m27-0-1
 *       maintainability
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.cstdiomacrosused.CstdioMacrosUsed

class CstdioMacrosUsedQuery extends CstdioMacrosUsedSharedQuery {
  CstdioMacrosUsedQuery() { this = BannedLibrariesPackage::cstdioMacrosUsedQuery() }
}
