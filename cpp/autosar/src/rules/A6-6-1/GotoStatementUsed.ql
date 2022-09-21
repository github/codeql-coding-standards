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

from Stmt s
where
  not isExcluded(s, BannedSyntaxPackage::gotoStatementUsedQuery()) and
  (s instanceof GotoStmt or s instanceof ComputedGotoStmt)
select s, "Use of goto."
