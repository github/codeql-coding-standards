/**
 * @id c/misra/return-statement-in-noreturn-function
 * @name RULE-17-9: Verify that a function declared with _Noreturn does not return
 * @description Returning inside a function declared with _Noreturn is undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-17-9
 *       correctness
 *       external/misra/c/2012/amendment3
 *       coding-standards/baseline/safety
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.functionnoreturnattributecondition.FunctionNoReturnAttributeCondition

class ReturnStatementInNoreturnFunctionQuery extends FunctionNoReturnAttributeConditionSharedQuery {
  ReturnStatementInNoreturnFunctionQuery() {
    this = NoReturnPackage::returnStatementInNoreturnFunctionQuery()
  }
}
