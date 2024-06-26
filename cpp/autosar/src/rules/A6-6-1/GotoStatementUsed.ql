/**
 * @id cpp/autosar/goto-statement-used
 * @name A6-6-1: The goto statement shall not be used
 * @description The goto statement shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a6-6-1
 *       correctness
 *       security
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.gotostatementshouldnotbeused_shared.GotoStatementShouldNotBeUsed_shared

class GotoStatementUsedQuery extends GotoStatementShouldNotBeUsed_sharedSharedQuery {
  GotoStatementUsedQuery() { this = BannedSyntaxPackage::gotoStatementUsedQuery() }
}
