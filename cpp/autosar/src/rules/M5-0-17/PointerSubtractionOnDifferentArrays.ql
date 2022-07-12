/**
 * @id cpp/autosar/pointer-subtraction-on-different-arrays
 * @name M5-0-17: Subtraction between pointers shall only be applied to pointers that address elements of the same array
 * @description Subtraction between pointers shall only be applied to pointers that address elements
 *              of the same array, otherwise subtraction results in undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/m5-0-17
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

class ArrayToPointerDiffOperandConfig extends DataFlow::Configuration {
  ArrayToPointerDiffOperandConfig() { this = "ArrayToPointerDiffOperandConfig" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr().(VariableAccess).getType() instanceof ArrayType
    or
    // Consider array to pointer decay for parameters.
    source.asExpr().(VariableAccess).getTarget().(Parameter).getType() instanceof ArrayType
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(PointerDiffExpr e | e.getAnOperand() = sink.asExpr())
  }

  override predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
    // Add a flow step from the base to the array expression to track pointers to elements of the array.
    exists(ArrayExpr e | e.getArrayBase() = pred.asExpr() and e = succ.asExpr())
  }
}

from
  PointerDiffExpr pointerSubstraction, Variable currentOperandPointee, Variable otherOperandPointee,
  DataFlow::PathNode source, DataFlow::PathNode sink, string side
where
  not isExcluded(pointerSubstraction, PointersPackage::pointerSubtractionOnDifferentArraysQuery()) and
  exists(ArrayToPointerDiffOperandConfig c, Variable sourceLeft, Variable sourceRight |
    c.hasFlow(DataFlow::exprNode(sourceLeft.getAnAccess()),
      DataFlow::exprNode(pointerSubstraction.getLeftOperand())) and
    c.hasFlow(DataFlow::exprNode(sourceRight.getAnAccess()),
      DataFlow::exprNode(pointerSubstraction.getRightOperand())) and
    not sourceLeft = sourceRight and
    c.hasFlowPath(source, sink) and
    (
      source.getNode().asExpr() = sourceLeft.getAnAccess() and
      sink.getNode().asExpr() = pointerSubstraction.getLeftOperand() and
      side = "left" and
      currentOperandPointee = sourceLeft and
      otherOperandPointee = sourceRight
      or
      source.getNode().asExpr() = sourceRight.getAnAccess() and
      sink.getNode().asExpr() = pointerSubstraction.getRightOperand() and
      side = "right" and
      currentOperandPointee = sourceRight and
      otherOperandPointee = sourceLeft
    )
  )
select sink.getNode(), source, sink,
  "Subtraction between " + side +
    " operand pointing to array $@ and other operand pointing to array $@.", currentOperandPointee,
  currentOperandPointee.getName(), otherOperandPointee, otherOperandPointee.getName()
