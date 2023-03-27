/**
 * @id c/misra/goto-statement-used
 * @name RULE-15-1: The goto statement should not be used
 * @description The goto statement shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-15-1
 *       correctness
 *       security
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from Stmt s
where
  not isExcluded(s, Statements6Package::gotoStatementUsedQuery()) and
  (s instanceof GotoStmt or s instanceof ComputedGotoStmt)
select s, "Use of goto."
