/**
 * @id cpp/autosar/condition-variable-post-condition-failed-autosar
 * @name A15-5-3: Failure to meet postcondition on condition_variable wait abruptly terminates the program
 * @description Abruptly terminating the program can leave resources such as streams and temporary
 *              files in an unclosed state.
 * @kind problem
 * @precision low
 * @problem.severity warning
 * @tags external/autosar/id/a15-5-3
 *       correctness
 *       external/autosar/audit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.conditionvariablepostconditionfailed.ConditionVariablePostConditionFailed

class ConditionVariablePostConditionFailedAutosarQuery extends ConditionVariablePostConditionFailedSharedQuery {
  ConditionVariablePostConditionFailedAutosarQuery() {
    this = Exceptions1Package::conditionVariablePostConditionFailedAutosarQuery()
  }
}
