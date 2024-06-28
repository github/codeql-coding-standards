/**
 * @id cpp/misra/cstdio-macros-shall-not-be-used
 * @name RULE-30-0-1: The stream input/output library <cstdio> macros shall not be used
 * @description The C Library input/output functions shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-30-0-1
 *       maintainability
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.cstdiomacrosused_shared.CstdioMacrosUsed_shared

class CstdioMacrosShallNotBeUsedQuery extends CstdioMacrosUsed_sharedSharedQuery {
  CstdioMacrosShallNotBeUsedQuery() {
    this = ImportMisra23Package::cstdioMacrosShallNotBeUsedQuery()
  }
}
