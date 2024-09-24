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
import codingstandards.c.Noreturn

from NoreturnFunction f
where
  not isExcluded(f, NoReturnPackage::returnStatementInNoreturnFunctionQuery()) and
  mayReturn(f)
select f, "The function " + f.getName() + " declared with attribute _Noreturn returns a value."
