/**
 * @id cpp/autosar/unused-parameter
 * @name A0-1-4: There shall be no unused named parameters in non-virtual functions
 * @description Unused parameters can indicate a mistake when implementing the function.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a0-1-4
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.deadcode.UnusedParameters
import codingstandards.cpp.rules.unusedparameter.UnusedParameter

module UnusedParameterQueryConfig implements UnusedParameterSharedConfigSig {
  Query getQuery() { result = DeadCodePackage::unusedParameterQuery() }

  predicate excludeParameter(Parameter p) {
    // Virtual functions are covered by a different rule
    p.getFunction().isVirtual()
  }
}

import UnusedParameterShared<UnusedParameterQueryConfig>
