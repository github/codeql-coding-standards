/**
 * @id cpp/cert/non-void-function-does-not-return-cert
 * @name MSC52-CPP: Value-returning functions must return a value from all exit paths
 * @description A function with non-void return type that does not exit via a return statement can
 *              result in undefined behaviour. An exception to this rule is exiting via exception
 *              handling.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/msc52-cpp
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p8
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.nonvoidfunctiondoesnotreturn.NonVoidFunctionDoesNotReturn

class NonVoidFunctionDoesNotReturnCertQuery extends NonVoidFunctionDoesNotReturnSharedQuery {
  NonVoidFunctionDoesNotReturnCertQuery() {
    this = FunctionsPackage::nonVoidFunctionDoesNotReturnCertQuery()
  }
}
