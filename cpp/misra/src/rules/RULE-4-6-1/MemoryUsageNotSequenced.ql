/**
 * @id cpp/misra/memory-usage-not-sequenced
 * @name RULE-4-6-1: Operations on a memory location shall be sequenced appropriately
 * @description Code behavior should not have unsequenced or indeterminately sequenced operations on
 *              the same memory location.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-4-6-1
 *       scope/system
 *       portability
 *       correctness
 *       maintainability
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.expressionwithunsequencedsideeffects.ExpressionWithUnsequencedSideEffects
import codingstandards.cpp.Ordering
import codingstandards.cpp.orderofevaluation.VariableAccessOrdering
import Ordering::Make<Cpp17VariableAccessInFullExpressionOrdering> as FullExprOrdering

module MemoryUsageNotSequencedConfig implements ExpressionWithUnsequencedSideEffectsConfigSig {
  Query getQuery() { result = SideEffects4Package::memoryUsageNotSequencedQuery() }

  predicate isUnsequenced(VariableAccess va1, VariableAccess va2) {
    FullExprOrdering::isUnsequenced(va1, va2)
  }
}

import ExpressionWithUnsequencedSideEffects<MemoryUsageNotSequencedConfig>
