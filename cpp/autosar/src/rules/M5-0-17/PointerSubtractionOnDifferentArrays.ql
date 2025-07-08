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
import semmle.code.cpp.dataflow.new.DataFlow
import ArrayToPointerDiffOperandFlow::PathGraph

module ArrayToPointerDiffOperandConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asExpr().(VariableAccess).getType() instanceof ArrayType
    or
    // Consider array to pointer decay for parameters.
    source.asExpr().(VariableAccess).getTarget().(Parameter).getType() instanceof ArrayType
  }

  predicate isSink(DataFlow::Node sink) {
    exists(PointerDiffExpr e | e.getAnOperand() = sink.asExpr())
  }

  predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
    // Add a flow step from the base to the array expression to track pointers to elements of the array.
    exists(ArrayExpr e | e.getArrayBase() = pred.asExpr() and e = succ.asExpr())
  }

  predicate isBarrierIn(DataFlow::Node node) { isSource(node) }
}

module ArrayToPointerDiffOperandFlow = DataFlow::Global<ArrayToPointerDiffOperandConfig>;

from
  PointerDiffExpr pointerSubstraction, Variable currentOperandPointee, Variable otherOperandPointee,
  ArrayToPointerDiffOperandFlow::PathNode source, ArrayToPointerDiffOperandFlow::PathNode sink,
  string side
where
  not isExcluded(pointerSubstraction, PointersPackage::pointerSubtractionOnDifferentArraysQuery()) and
  exists(Variable sourceLeft, Variable sourceRight |
    ArrayToPointerDiffOperandFlow::flow(DataFlow::exprNode(sourceLeft.getAnAccess()),
      DataFlow::exprNode(pointerSubstraction.getLeftOperand())) and
    ArrayToPointerDiffOperandFlow::flow(DataFlow::exprNode(sourceRight.getAnAccess()),
      DataFlow::exprNode(pointerSubstraction.getRightOperand())) and
    not sourceLeft = sourceRight and
    ArrayToPointerDiffOperandFlow::flowPath(source, sink) and
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
