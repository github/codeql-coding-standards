/**
 * @id c/cert/preserve-safety-when-using-condition-variables
 * @name CON38-C: Preserve thread safety and liveness when using condition variables
 * @description Usages of `cnd_signal` with non-unique condition variables may impact thread safety
 *              and liveness.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/con38-c
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
import codingstandards.c.cert
import codingstandards.cpp.rules.preservesafetywhenusingconditionvariables.PreserveSafetyWhenUsingConditionVariables

class PreserveSafetyWhenUsingConditionVariablesQuery extends PreserveSafetyWhenUsingConditionVariablesSharedQuery
{
  PreserveSafetyWhenUsingConditionVariablesQuery() {
    this = Concurrency3Package::preserveSafetyWhenUsingConditionVariablesQuery()
  }
}
