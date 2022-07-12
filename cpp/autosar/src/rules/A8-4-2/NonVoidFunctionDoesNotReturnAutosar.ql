/**
 * @id cpp/autosar/non-void-function-does-not-return-autosar
 * @name A8-4-2: All exit paths from a function with non-void return type shall have an explicit return statement
 * @description A function with non-void return type that does not exit via a return statement can
 *              result in undefined behaviour. An exception to this rule is exiting via exception
 *              handling.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a8-4-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.nonvoidfunctiondoesnotreturn.NonVoidFunctionDoesNotReturn

class NonVoidFunctionDoesNotReturnAutosarQuery extends NonVoidFunctionDoesNotReturnSharedQuery {
  NonVoidFunctionDoesNotReturnAutosarQuery() {
    this = FunctionsPackage::nonVoidFunctionDoesNotReturnAutosarQuery()
  }
}
