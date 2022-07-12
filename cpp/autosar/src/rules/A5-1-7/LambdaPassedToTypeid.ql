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
import DataFlow::PathGraph

class LambdaExpressionToTypeid extends DataFlow::Configuration {
  LambdaExpressionToTypeid() { this = "LambdaExpressionToTypeid" }

  override predicate isSource(DataFlow::Node source) { source.asExpr() instanceof LambdaExpression }

  override predicate isSink(DataFlow::Node sink) {
    exists(TypeidOperator op | op.getExpr() = sink.asExpr())
  }
}

from DataFlow::PathNode source, DataFlow::PathNode sink
where
  not isExcluded(source.getNode().asExpr(), LambdasPackage::lambdaPassedToTypeidQuery()) and
  any(LambdaExpressionToTypeid config).hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Lambda $@ passed as operand to typeid operator.",
  source.getNode(), "expression"
