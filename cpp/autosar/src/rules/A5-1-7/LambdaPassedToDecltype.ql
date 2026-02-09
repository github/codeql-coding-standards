/**
 * @id cpp/autosar/lambda-passed-to-decltype
 * @name A5-1-7: A lambda shall not be an operand to decltype
 * @description Each lambda expression has a unique type and the result when passed to decltype can
 *              result in unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a5-1-7
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.dataflow.DataFlow

module LambdaExpressionToInitializerConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source.asExpr() instanceof LambdaExpression }

  predicate isSink(DataFlow::Node sink) {
    exists(Variable v | v.getInitializer().getExpr() = sink.asExpr())
  }
}

module LambdaExpressionToInitializerFlow = DataFlow::Global<LambdaExpressionToInitializerConfig>;

from Decltype dt, LambdaExpression lambda
where
  not isExcluded(dt, LambdasPackage::lambdaPassedToDecltypeQuery()) and
  (
    dt.getExpr() = lambda
    or
    exists(VariableAccess va, Variable v |
      dt.getExpr() = va and
      v = va.getTarget() and
      LambdaExpressionToInitializerFlow::flow(DataFlow::exprNode(lambda),
        DataFlow::exprNode(v.getInitializer().getExpr()))
    )
  )
select dt, "Lambda $@ passed as operand to decltype.", lambda, "expression"
