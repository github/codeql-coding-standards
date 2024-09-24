/**
 * @id c/misra/function-with-no-returning-branch-should-be-noreturn
 * @name RULE-17-11: A function without a branch that returns shall be declared with _Noreturn
 * @description Functions which cannot return should be declared with _Noreturn.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-17-11
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from Function f
where
  not isExcluded(f, NoReturnPackage::returnStatementInNoreturnFunctionQuery()) and
  not f.getASpecifier().getName() = "noreturn" and
  not exists(ReturnStmt s |
    f = s.getEnclosingFunction() and
    s.getBasicBlock().isReachable()
  )
select
  f, "The function " + f.getName() + " cannot return and should be declared attribute _Noreturn."
