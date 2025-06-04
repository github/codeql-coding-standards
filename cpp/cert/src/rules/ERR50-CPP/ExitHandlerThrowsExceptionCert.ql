/**
 * @id cpp/cert/exit-handler-throws-exception-cert
 * @name ERR50-CPP: Registered exit handler throws an exception
 * @description An exit handler which throws an exception causes abrupt termination of the program,
 *              and can leave resources such as streams and temporary files in an unclosed state.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err50-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.exithandlerthrowsexception.ExitHandlerThrowsException

class ExitHandlerThrowsExceptionCertQuery extends ExitHandlerThrowsExceptionSharedQuery {
  ExitHandlerThrowsExceptionCertQuery() {
    this = Exceptions1Package::exitHandlerThrowsExceptionCertQuery()
  }
}
