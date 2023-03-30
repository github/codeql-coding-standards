/**
 * @id c/misra/non-void-function-return-condition
 * @name RULE-17-4: All exit paths from a function with non-void return type shall have an explicit return statement
 * @description Not returning with an expression from a non-void function can lead to undefined
 *              behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-17-4
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.nonvoidfunctiondoesnotreturn.NonVoidFunctionDoesNotReturn

class NonVoidFunctionReturnConditionQuery extends NonVoidFunctionDoesNotReturnSharedQuery {
  NonVoidFunctionReturnConditionQuery() {
    this = Statements5Package::nonVoidFunctionReturnConditionQuery()
  }
}
