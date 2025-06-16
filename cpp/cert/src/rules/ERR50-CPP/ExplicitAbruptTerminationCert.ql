/**
 * @id cpp/cert/explicit-abrupt-termination-cert
 * @name ERR50-CPP: Do not explicitly abruptly terminate the program
 * @description Abruptly terminating the program can leave resources such as streams and temporary
 *              files in an unclosed state.
 * @kind problem
 * @precision very-high
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
import codingstandards.cpp.rules.explicitabrupttermination.ExplicitAbruptTermination

class ExplicitAbruptTerminationCertQuery extends ExplicitAbruptTerminationSharedQuery {
  ExplicitAbruptTerminationCertQuery() {
    this = Exceptions1Package::explicitAbruptTerminationCertQuery()
  }
}
