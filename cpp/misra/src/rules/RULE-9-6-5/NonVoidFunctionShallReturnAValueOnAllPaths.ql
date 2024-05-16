/**
 * @id cpp/misra/non-void-function-shall-return-a-value-on-all-paths
 * @name RULE-9-6-5: A function with non-void return type shall return a value on all paths
 * @description A function with non-void return type that does not exit via a return statement can
 *              result in undefined behaviour. An exception to this rule is exiting via exception
 *              handling.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-9-6-5
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.nonvoidfunctiondoesnotreturn.NonVoidFunctionDoesNotReturn

class NonVoidFunctionShallReturnAValueOnAllPathsQuery extends NonVoidFunctionDoesNotReturnSharedQuery {
  NonVoidFunctionShallReturnAValueOnAllPathsQuery() {
    this = ImportMisra23Package::nonVoidFunctionShallReturnAValueOnAllPathsQuery()
  }
}
