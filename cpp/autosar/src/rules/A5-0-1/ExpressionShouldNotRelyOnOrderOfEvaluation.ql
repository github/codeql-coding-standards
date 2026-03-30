/**
 * @id cpp/autosar/expression-should-not-rely-on-order-of-evaluation
 * @name A5-0-1: The value of an expression does not rely on the order of evaluation
 * @description The value of an expression shall be the same under any order of evaluation that the
 *              standard permits.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a5-0-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.expressionwithunsequencedsideeffects.ExpressionWithUnsequencedSideEffects
import codingstandards.cpp.Ordering
import codingstandards.cpp.orderofevaluation.VariableAccessOrdering
import Ordering::Make<Cpp14VariableAccessInFullExpressionOrdering> as FullExprOrdering

module ExpressionShouldNotRelyOnOrderOfEvaluationConfig implements
  ExpressionWithUnsequencedSideEffectsConfigSig
{
  Query getQuery() {
    result = OrderOfEvaluationPackage::expressionShouldNotRelyOnOrderOfEvaluationQuery()
  }

  predicate isUnsequenced(VariableAccess va1, VariableAccess va2) {
    FullExprOrdering::isUnsequenced(va1, va2)
  }
}

import ExpressionWithUnsequencedSideEffects<ExpressionShouldNotRelyOnOrderOfEvaluationConfig>
