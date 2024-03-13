/**
 * Provides a library which includes a `problems` predicate for reporting
 * instances of the >, >=, <, and <= operators being applied to pointers
 * which address different arrays.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.DataFlow
import ArrayToRelationalOperationOperandFlow::PathGraph

abstract class DoNotUseRelationalOperatorsWithDifferingArraysSharedQuery extends Query { }

Query getQuery() { result instanceof DoNotUseRelationalOperatorsWithDifferingArraysSharedQuery }

/** A source of arrays that can be used to start tracking data flow originating from an array. */
abstract class ArraySource extends DataFlow::Node { }

/** An access of an object of array type. */
class ArrayAccess extends ArraySource {
  ArrayAccess() { this.asExpr().(VariableAccess).getType() instanceof ArrayType }
}

/** An access of an object of array type through a pointer that is the result of an array to pointer decay. */
class DecayedArrayAccess extends ArraySource {
  DecayedArrayAccess() {
    exists(VariableAccess va | va = this.asExpr() |
      va.getType() instanceof PointerType and
      va.getTarget().(Parameter).getType() instanceof ArrayType
    )
  }
}

module ArrayToRelationalOperationOperandConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof ArraySource }

  predicate isSink(DataFlow::Node sink) {
    exists(RelationalOperation op | op.getAnOperand() = sink.asExpr())
  }

  predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
    // Add a flow step from the base to the array expression to track pointers to elements of the array.
    exists(ArrayExpr e | e.getArrayBase() = pred.asExpr() and e = succ.asExpr())
  }
}

module ArrayToRelationalOperationOperandFlow =
  DataFlow::Global<ArrayToRelationalOperationOperandConfig>;

predicate isComparingPointers(RelationalOperation op) {
  forall(Expr operand | operand = op.getAnOperand() |
    operand.getType() instanceof PointerType or operand.getType() instanceof ArrayType
  )
}

query predicate problems(
  RelationalOperation compare, ArrayToRelationalOperationOperandFlow::PathNode source,
  ArrayToRelationalOperationOperandFlow::PathNode sink, string message,
  Variable selectedOperandPointee, string selectedOperandPointeeName, Variable otherOperandPointee,
  string otherOperandPointeeName
) {
  not isExcluded(compare, getQuery()) and
  exists(Variable sourceLeft, Variable sourceRight, string side |
    ArrayToRelationalOperationOperandFlow::flow(DataFlow::exprNode(sourceLeft.getAnAccess()),
      DataFlow::exprNode(compare.getLeftOperand())) and
    ArrayToRelationalOperationOperandFlow::flow(DataFlow::exprNode(sourceRight.getAnAccess()),
      DataFlow::exprNode(compare.getRightOperand())) and
    not sourceLeft = sourceRight and
    isComparingPointers(compare) and
    ArrayToRelationalOperationOperandFlow::flowPath(source, sink) and
    (
      source.getNode().asExpr() = sourceLeft.getAnAccess() and
      sink.getNode().asExpr() = compare.getLeftOperand() and
      selectedOperandPointee = sourceLeft and
      otherOperandPointee = sourceRight and
      side = "left"
      or
      source.getNode().asExpr() = sourceRight.getAnAccess() and
      sink.getNode().asExpr() = compare.getRightOperand() and
      selectedOperandPointee = sourceRight and
      otherOperandPointee = sourceLeft and
      side = "right"
    ) and
    selectedOperandPointeeName = selectedOperandPointee.getName() and
    otherOperandPointeeName = otherOperandPointee.getName() and
    message =
      "Compare operation " + compare.getOperator() + " comparing " + side +
        " operand pointing to array $@ and other operand pointing to array $@."
  )
}
