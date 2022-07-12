/**
 * @id cpp/autosar/pointer-and-derived-pointer-access-different-array
 * @name M5-0-16: A pointer operand and any pointer resulting from pointer arithmetic using that operand shall both
 * @description A pointer operand and any pointer resulting from pointer arithmetic using that
 *              operand shall both address elements of the same array.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/autosar/id/m5-0-16
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

/**
 * A data-flow configuration that tracks access to an array to type to an array index expression.
 * This is used to determine possible pointer to array creations.
 */
class ArrayToArrayExprConfig extends DataFlow::Configuration {
  ArrayToArrayExprConfig() { this = "ArrayToArrayIndexConfig" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr().(VariableAccess).getType() instanceof ArrayType
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(ArrayExpr c | c.getArrayBase() = sink.asExpr())
  }
}

/** Holds if the address taken expression `addressOf` takes the address of an array element at `index` of `array` with size `arraySize`. */
predicate pointerOperandCreation(AddressOfExpr addressOf, Variable array, int arraySize, int index) {
  arraySize = array.getType().(ArrayType).getArraySize() and
  exists(ArrayExpr ae |
    any(ArrayToArrayExprConfig cfg)
        .hasFlow(DataFlow::exprNode(array.getAnAccess()), DataFlow::exprNode(ae.getArrayBase())) and
    index = lowerBound(ae.getArrayOffset().getFullyConverted()) and
    addressOf.getOperand() = ae
  )
}

/** A variable that points to an element of an array. */
class PointerOperand extends Variable {
  Variable array;
  int arraySize;
  int index;
  AddressOfExpr source;

  PointerOperand() {
    pointerOperandCreation(source, array, arraySize, index) and
    this.getAnAssignedValue() = source
  }

  Variable getArray() { result = array }

  int getArraySize() { result = arraySize }

  int getIndex() { result = index }

  AddressOfExpr getSource() { result = source }
}

/** An derivation of a new pointer that differs by a constant amount. */
class ConstantPointerAdjustment extends Expr {
  int delta;

  ConstantPointerAdjustment() {
    delta = this.(PointerAddExpr).getAnOperand().getValue().toInt()
    or
    delta = -this.(PointerSubExpr).getAnOperand().getValue().toInt()
    or
    this.(Operation).getAnOperand().getUnderlyingType() instanceof PointerType and
    (
      delta = 0 and this instanceof PostfixCrementOperation
      or
      delta = 1 and this instanceof PrefixIncrExpr
      or
      delta = -1 and this instanceof PrefixDecrExpr
    )
    or
    this.(VariableAccess).getUnderlyingType() instanceof PointerType and delta = 0
  }

  int getDelta() { result = delta }

  VariableAccess getAdjusted() {
    result = this
    or
    result = this.(Operation).getAnOperand()
  }
}

/** Holds if `derivedPointer` is a new pointer created via an `adjustment` on `pointerOperand`. */
predicate derivedPointer(
  Variable derivedPointer, ConstantPointerAdjustment adjustment,
  DerivedArrayPointerOrPointerOperand pointerOperand, int index
) {
  adjustment.getAdjusted().getTarget() = pointerOperand and
  index = pointerOperand.getIndex() + adjustment.getDelta() and
  derivedPointer.getAnAssignedValue() = adjustment
}

/**
 * A pointer to an array that is derived from another pointer to an array through a constant adjustment.
 * The new pointer may or may not point to the same array.
 */
class DerivedArrayPointer extends Variable {
  DerivedArrayPointerOrPointerOperand operand;
  int index;
  ConstantPointerAdjustment source;

  DerivedArrayPointer() { derivedPointer(this, source, operand, index) }

  Variable getArray() { result = operand.getArray() }

  int getArraySize() { result = operand.getArraySize() }

  int getIndex() { result = index }

  ConstantPointerAdjustment getSource() { result = source }
}

/**
 * A pointer to an element of array created by taking the address of an array element or
 * created through a constant adjustment of a pointer to an array.
 */
class DerivedArrayPointerOrPointerOperand extends Variable {
  DerivedArrayPointerOrPointerOperand() {
    this instanceof DerivedArrayPointer
    or
    this instanceof PointerOperand
  }

  Variable getArray() {
    result = this.(DerivedArrayPointer).getArray() or result = this.(PointerOperand).getArray()
  }

  int getArraySize() {
    result = this.(DerivedArrayPointer).getArraySize() or
    result = this.(PointerOperand).getArraySize()
  }

  int getIndex() {
    result = this.(DerivedArrayPointer).getIndex() or result = this.(PointerOperand).getIndex()
  }

  Expr getSource() {
    result = this.(DerivedArrayPointer).getSource() or result = this.(PointerOperand).getSource()
  }
}

from
  Expr arrayPointerCreation,
  DerivedArrayPointerOrPointerOperand derivedArrayPointerOrPointerOperand, Variable array,
  int index, int arraySize, int difference, string denomination
where
  not isExcluded(arrayPointerCreation,
    PointersPackage::pointerAndDerivedPointerAccessDifferentArrayQuery()) and
  array = derivedArrayPointerOrPointerOperand.getArray() and
  arraySize = derivedArrayPointerOrPointerOperand.getArraySize() and
  index = derivedArrayPointerOrPointerOperand.getIndex() and
  arrayPointerCreation = derivedArrayPointerOrPointerOperand.getSource() and
  difference = index - arraySize and
  (
    difference = 1 and denomination = "element"
    or
    difference > 1 and denomination = "elements"
  ) and
  // Exclude the creation of pointers to an element of an array in loops.
  // Our range analysis will typically resort to widening resulting in
  // possible false positives.
  not exists(Loop loop |
    arrayPointerCreation.getEnclosingBlock().getEnclosingBlock*() = loop.getStmt()
  )
select arrayPointerCreation,
  "Array pointer " + derivedArrayPointerOrPointerOperand.getName() + " points " +
    (index - arraySize).toString() + " " + denomination + " passed the end of $@.", array,
  array.getName()
