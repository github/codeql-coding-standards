/**
 * @id cpp/cert/condition-variable-post-condition-failed-cert
 * @name ERR50-CPP: Failure to meet postcondition on condition_variable wait abruptly terminates the program
 * @description Abruptly terminating the program can leave resources such as streams and temporary
 *              files in an unclosed state.
 * @kind problem
 * @precision low
 * @problem.severity warning
 * @tags external/cert/id/err50-cpp
 *       correctness
 *       external/cert/audit
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.conditionvariablepostconditionfailed.ConditionVariablePostConditionFailed

class ConditionVariablePostConditionFailedCertQuery extends ConditionVariablePostConditionFailedSharedQuery
{
  ConditionVariablePostConditionFailedCertQuery() {
    this = Exceptions1Package::conditionVariablePostConditionFailedCertQuery()
  }
}
