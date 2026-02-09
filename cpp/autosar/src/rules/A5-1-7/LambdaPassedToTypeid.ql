/**
 * @id cpp/autosar/lambda-passed-to-typeid
 * @name A5-1-7: A lambda shall not be an operand to typeid
 * @description Each lambda expression has a unique type and the result when passed to typeid can
 *              result in unexpected behavior.
 * @kind path-problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a5-1-7
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.autosar
import LambdaExpressionToTypeidFlow::PathGraph

module LambdaExpressionToTypeidConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source.asExpr() instanceof LambdaExpression }

  predicate isSink(DataFlow::Node sink) { exists(TypeidOperator op | op.getExpr() = sink.asExpr()) }
}

module LambdaExpressionToTypeidFlow = DataFlow::Global<LambdaExpressionToTypeidConfig>;

from LambdaExpressionToTypeidFlow::PathNode source, LambdaExpressionToTypeidFlow::PathNode sink
where
  not isExcluded(source.getNode().asExpr(), LambdasPackage::lambdaPassedToTypeidQuery()) and
  LambdaExpressionToTypeidFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Lambda $@ passed as operand to typeid operator.",
  source.getNode(), "expression"
