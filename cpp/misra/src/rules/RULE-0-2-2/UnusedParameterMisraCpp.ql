/**
 * @id cpp/misra/unused-parameter-misra-cpp
 * @name RULE-0-2-2: There shall be no unused named parameters in non-virtual functions
 * @description Unused parameters can indicate a mistake when implementing the function.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-0-2-2
 *       scope/single-translation-unit
 *       readability
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra as Misra
import codingstandards.cpp.rules.unusedparameter.UnusedParameter

module UnusedParameterQueryConfig implements UnusedParameterSharedConfigSig {
  Query getQuery() { result = Misra::DeadCode8Package::unusedParameterMisraCppQuery() }

  predicate excludeParameter(Parameter p) {
    // Exclude parameters which are unnamed in the definition.
    not exists(p.getFunction().getDefinition().getParameterDeclarationEntry(p.getIndex()).getName())
  }
}

import UnusedParameterShared<UnusedParameterQueryConfig>
