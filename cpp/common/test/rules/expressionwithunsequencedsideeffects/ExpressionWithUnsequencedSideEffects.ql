import codingstandards.cpp.rules.expressionwithunsequencedsideeffects.ExpressionWithUnsequencedSideEffects
import codingstandards.cpp.Ordering
import codingstandards.cpp.orderofevaluation.VariableAccessOrdering
import Ordering::Make<Cpp14VariableAccessInFullExpressionOrdering> as FullExprOrdering

module TestFileConfig implements ExpressionWithUnsequencedSideEffectsConfigSig {
  Query getQuery() { result instanceof TestQuery }

  predicate isUnsequenced(VariableAccess va1, VariableAccess va2) {
    FullExprOrdering::isUnsequenced(va1, va2)
  }
}

import ExpressionWithUnsequencedSideEffects<TestFileConfig>
