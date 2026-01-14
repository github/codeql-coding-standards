/**
 * @id cpp/misra/pointer-arithmetic-forms-an-invalid-pointer
 * @name RULE-8-7-1: Pointer arithmetic shall not form an invalid pointer.
 * @description Pointers obtained as result of performing arithmetic should point to an initialized
 *              object, or an element right next to the last element of an array.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-7-1
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.security.BufferAccess

class ArrayDeclaration extends VariableDeclarationEntry {
  int length;

  ArrayDeclaration() { this.getType().getUnderlyingType().(ArrayType).getArraySize() = length }

  /**
   * Gets the declared length of this array.
   */
  int getLength() { result = length }

  /**
   * Gets the expression that the variable declared is initialized to, given there is such one.
   */
  Expr getInitExpr() { result = this.getVariable().getInitializer().getExpr() }
}

newtype TArrayAllocation =
  TStackAllocation(ArrayDeclaration arrayDecl) or
  TDynamicAllocation(AllocationFunction alloc)

newtype TPointerFormation =
  TArrayExpr(ArrayExprBA arrayExpr) or
  TPointerArithmetic(PointerArithmeticOperation pointerArithmetic)

class ArrayAllocation extends TArrayAllocation {
  ArrayDeclaration asStackAllocation() { this = TStackAllocation(result) }

  AllocationFunction asDynamicAllocation() { this = TDynamicAllocation(result) }

  string toString() {
    result = this.asStackAllocation().toString() or
    result = this.asDynamicAllocation().toString()
  }

  int getLength() {
    result = this.asStackAllocation().getLength() or
    none() // TODO: this.asDynamicAllocation()
  }

  Location getLocation() {
    result = this.asStackAllocation().getLocation() or
    result = this.asDynamicAllocation().getLocation()
  }
}

class PointerFormation extends TPointerFormation {
  ArrayExprBA asArrayExpr() { this = TArrayExpr(result) }

  PointerArithmeticOperation asPointerArithmetic() { this = TPointerArithmetic(result) }

  string toString() {
    result = this.asArrayExpr().toString() or
    result = this.asPointerArithmetic().toString()
  }

  int getOffset() {
    result = this.asArrayExpr().getArrayOffset().getValue().toInt()
    or
    exists(PointerAddExpr pointerAddition | pointerAddition = this.asPointerArithmetic() |
      result = pointerAddition.getAnOperand().getValue().toInt() // TODO: only get the number being added
    )
    or
    exists(PointerSubExpr pointerSubtraction | pointerSubtraction = this.asPointerArithmetic() |
      result = -pointerSubtraction.getAnOperand().getValue().toInt()
    )
  }

  Expr asExpr() {
    result = this.asArrayExpr() or
    result = this.asPointerArithmetic()
  }

  DataFlow::Node getNode() {
    result.asExpr() = this.asExpr() or
    result.asIndirectExpr() = this.asExpr()
  }

  Location getLocation() {
    result = this.asArrayExpr().getLocation() or
    result = this.asPointerArithmetic().getLocation()
  }
}

module TrackArrayConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) {
    /* 1. Declaring / Initializing an array-type variable */
    exists(ArrayAllocation arrayAllocation |
      node.asExpr() = arrayAllocation.asStackAllocation().getInitExpr()
    )
    or
    /* 2. Allocating dynamic memory as an array */
    none() // TODO
  }

  predicate isSink(DataFlow::Node node) {
    exists(PointerFormation pointerFormation | node = pointerFormation.getNode())
  }
}

module TrackArray = DataFlow::Global<TrackArrayConfig>;

private predicate arrayDeclarationAndAccess(
  DataFlow::Node arrayDeclarationNode, DataFlow::Node pointerFormationNode
) {
  TrackArray::flow(arrayDeclarationNode, pointerFormationNode)
}

private predicate arrayIndexExceedsOutOfBounds(
  DataFlow::Node arrayDeclarationNode, DataFlow::Node pointerFormationNode
) {
  /* 1. Ensure the array access is reachable from the array declaration. */
  arrayDeclarationAndAccess(arrayDeclarationNode, pointerFormationNode) and
  exists(ArrayAllocation arrayAllocation, PointerFormation pointerFormation |
    arrayDeclarationNode.asExpr() = arrayAllocation.asStackAllocation().getInitExpr() and
    pointerFormationNode = pointerFormation.getNode()
  |
    /* 2. Cases where a pointer formation becomes illegal. */
    (
      /* 2-1. An offset cannot be negative. */
      pointerFormation.getOffset() < 0
      or
      /* 2-2. The offset should be at most (number of elements) + 1 = (the declared length). */
      arrayAllocation.getLength() < pointerFormation.getOffset()
    )
  )
}

from PointerFormation pointerFormation
where
  not isExcluded(pointerFormation.asExpr(),
    Memory1Package::pointerArithmeticFormsAnInvalidPointerQuery()) and
  exists(DataFlow::Node pointerFormationNode | pointerFormationNode = pointerFormation.getNode() |
    arrayIndexExceedsOutOfBounds(_, pointerFormationNode)
  )
select pointerFormation, "TODO"
