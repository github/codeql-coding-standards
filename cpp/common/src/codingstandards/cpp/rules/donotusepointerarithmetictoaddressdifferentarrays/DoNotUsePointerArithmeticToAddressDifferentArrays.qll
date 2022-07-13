/**
 * Provides a library which includes a `problems` predicate for reporting
 * pointer arithmetic expressions in which the resulting pointer addresses an array
 * other than the array which the original pointer operand addressed.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

abstract class DoNotUsePointerArithmeticToAddressDifferentArraysSharedQuery extends Query { }

Query getQuery() { result instanceof DoNotUsePointerArithmeticToAddressDifferentArraysSharedQuery }

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

query predicate problems(Expr arrayPointerCreation, string message, Variable array, string arrayName) {
  not isExcluded(arrayPointerCreation, getQuery()) and
  exists(
    DerivedArrayPointerOrPointerOperand derivedArrayPointerOrPointerOperand, int index,
    int arraySize, int difference, string denomination
  |
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
    ) and
    message =
      "Array pointer " + derivedArrayPointerOrPointerOperand.getName() + " points " +
        (index - arraySize).toString() + " " + denomination + " passed the end of $@."
  ) and
  arrayName = array.getName()
}
