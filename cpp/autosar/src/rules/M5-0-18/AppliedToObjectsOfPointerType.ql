/**
 * @id cpp/autosar/applied-to-objects-of-pointer-type
 * @name M5-0-18: >, >=, <, <= shall not be applied to pointers pointing to different arrays
 * @description >, >=, <, <= applied to objects of pointer type produces undefined behavior, except
 *              where they point to the same array.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/m5-0-18
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

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

class ArrayToRelationalOperationOperandConfig extends DataFlow::Configuration {
  ArrayToRelationalOperationOperandConfig() { this = "ArrayToRelationalOperationOperandConfig" }

  override predicate isSource(DataFlow::Node source) { source instanceof ArraySource }

  override predicate isSink(DataFlow::Node sink) {
    exists(RelationalOperation op | op.getAnOperand() = sink.asExpr())
  }

  override predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
    // Add a flow step from the base to the array expression to track pointers to elements of the array.
    exists(ArrayExpr e | e.getArrayBase() = pred.asExpr() and e = succ.asExpr())
  }
}

predicate isComparingPointers(RelationalOperation op) {
  forall(Expr operand | operand = op.getAnOperand() |
    operand.getType() instanceof PointerType or operand.getType() instanceof ArrayType
  )
}

from
  RelationalOperation compare, DataFlow::PathNode source, DataFlow::PathNode sink,
  Variable selectedOperandPointee, Variable otherOperandPointee, string side
where
  not isExcluded(compare, PointersPackage::appliedToObjectsOfPointerTypeQuery()) and
  exists(ArrayToRelationalOperationOperandConfig c, Variable sourceLeft, Variable sourceRight |
    c.hasFlow(DataFlow::exprNode(sourceLeft.getAnAccess()),
      DataFlow::exprNode(compare.getLeftOperand())) and
    c.hasFlow(DataFlow::exprNode(sourceRight.getAnAccess()),
      DataFlow::exprNode(compare.getRightOperand())) and
    not sourceLeft = sourceRight and
    isComparingPointers(compare) and
    c.hasFlowPath(source, sink) and
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
    )
  )
select compare, source, sink,
  "Compare operation " + compare.getOperator() + " comparing " + side +
    " operand pointing to array $@ and other operand pointing to array $@.", selectedOperandPointee,
  selectedOperandPointee.getName(), otherOperandPointee, otherOperandPointee.getName()
