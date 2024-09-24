/**
 * @id c/misra/return-statement-in-noreturn-function
 * @name RULE-17-9: Verify that a function declared with _Noreturn does not return
 * @description Returning inside a function declared with _Noreturn is undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-17-9
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra

from Function f
where
  not isExcluded(f, NoReturnPackage::returnStatementInNoreturnFunctionQuery()) and
  f.getASpecifier().getName() = "noreturn" and
  exists(ReturnStmt s |
    f = s.getEnclosingFunction() and
    s.getBasicBlock().isReachable()
  )
select
  f, "The function " + f.getName() + " declared with attribute _Noreturn returns a value."
