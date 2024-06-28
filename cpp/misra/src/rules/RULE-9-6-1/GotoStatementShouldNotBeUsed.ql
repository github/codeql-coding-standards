/**
 * @id cpp/misra/goto-statement-should-not-be-used
 * @name RULE-9-6-1: The goto statement should not be used
 * @description The goto statement should not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-9-6-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.gotostatementshouldnotbeused_shared.GotoStatementShouldNotBeUsed_shared

class GotoStatementShouldNotBeUsedQuery extends GotoStatementShouldNotBeUsed_sharedSharedQuery {
  GotoStatementShouldNotBeUsedQuery() {
    this = ImportMisra23Package::gotoStatementShouldNotBeUsedQuery()
  }
}
