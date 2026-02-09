/**
 * Provides a library which includes a `problems` predicate for reporting
 * subtraction between operands pointing to differing arrays.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.DataFlow
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
}

module ArrayToPointerDiffOperandFlow = DataFlow::Global<ArrayToPointerDiffOperandConfig>;

abstract class DoNotSubtractPointersAddressingDifferentArraysSharedQuery extends Query { }

Query getQuery() { result instanceof DoNotSubtractPointersAddressingDifferentArraysSharedQuery }

query predicate problems(
  DataFlow::Node sinkNode, ArrayToPointerDiffOperandFlow::PathNode source,
  ArrayToPointerDiffOperandFlow::PathNode sink, string message, Variable currentOperandPointee,
  string currentOperandPointeeName, Variable otherOperandPointee, string otherOperandPointeeName
) {
  exists(
    PointerDiffExpr pointerSubtraction, string side, Variable sourceLeft, Variable sourceRight
  |
    not isExcluded(pointerSubtraction, getQuery()) and
    ArrayToPointerDiffOperandFlow::flow(DataFlow::exprNode(sourceLeft.getAnAccess()),
      DataFlow::exprNode(pointerSubtraction.getLeftOperand())) and
    ArrayToPointerDiffOperandFlow::flow(DataFlow::exprNode(sourceRight.getAnAccess()),
      DataFlow::exprNode(pointerSubtraction.getRightOperand())) and
    not sourceLeft = sourceRight and
    ArrayToPointerDiffOperandFlow::flowPath(source, sink) and
    (
      source.getNode().asExpr() = sourceLeft.getAnAccess() and
      sink.getNode().asExpr() = pointerSubtraction.getLeftOperand() and
      side = "left" and
      currentOperandPointee = sourceLeft and
      otherOperandPointee = sourceRight
      or
      source.getNode().asExpr() = sourceRight.getAnAccess() and
      sink.getNode().asExpr() = pointerSubtraction.getRightOperand() and
      side = "right" and
      currentOperandPointee = sourceRight and
      otherOperandPointee = sourceLeft
    ) and
    sinkNode = sink.getNode() and
    currentOperandPointeeName = currentOperandPointee.getName() and
    otherOperandPointeeName = otherOperandPointee.getName() and
    message =
      "Subtraction between " + side +
        " operand pointing to array $@ and other operand pointing to array $@."
  )
}
