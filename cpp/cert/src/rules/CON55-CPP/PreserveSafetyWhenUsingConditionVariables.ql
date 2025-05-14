/**
 * @id cpp/cert/preserve-safety-when-using-condition-variables
 * @name CON55-CPP: Preserve thread safety and liveness when using condition variables
 * @description Usage of `notify_one` within a thread can lead to potential deadlocks and liveness
 *              problems.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con55-cpp
 *       correctness
 *       concurrency
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.preservesafetywhenusingconditionvariables.PreserveSafetyWhenUsingConditionVariables

class PreserveSafetyWhenUsingConditionVariablesQuery extends PreserveSafetyWhenUsingConditionVariablesSharedQuery
{
  PreserveSafetyWhenUsingConditionVariablesQuery() {
    this = ConcurrencyPackage::preserveSafetyWhenUsingConditionVariablesQuery()
  }
}
