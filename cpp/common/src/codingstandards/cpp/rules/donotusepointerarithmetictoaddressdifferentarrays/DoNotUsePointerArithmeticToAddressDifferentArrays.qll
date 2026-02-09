/**
 * Provides a library which includes a `problems` predicate for reporting
 * pointer arithmetic expressions in which the resulting pointer addresses an array
 * other than the array which the original pointer operand addressed.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
import semmle.code.cpp.rangeanalysis.RangeAnalysisUtils
import codeql.util.Boolean

abstract class DoNotUsePointerArithmeticToAddressDifferentArraysSharedQuery extends Query { }

Query getQuery() { result instanceof DoNotUsePointerArithmeticToAddressDifferentArraysSharedQuery }

/**
 * A `VariableAccess` of a variable that is an array, or a pointer type casted to a byte pointer.
 */
abstract class ArrayLikeAccess extends Expr {
  abstract Element getElement();

  abstract string getName();

  abstract int getSize();

  abstract DataFlow::Node getNode();
}

/**
 * A `VariableAccess` of a variable that is an array.
 */
class ArrayVariableAccess extends ArrayLikeAccess, VariableAccess {
  int size;

  ArrayVariableAccess() { size = getType().(ArrayType).getArraySize() }

  override Variable getElement() { result = getTarget() }

  override string getName() { result = getElement().getName() }

  override int getSize() { result = size }

  override DataFlow::Node getNode() { result.asExpr() = this }
}

/**
 * Get the size of the object pointed to by a type (pointer or array).
 *
 * Depth of type unwrapping depends on the type. Pointer will be dereferenced only once: the element
 * size of `T*` is `sizeof(T)` while the element size of `T**` is `sizeof(T*)`. However, array types
 * will be deeply unwrapped, as the pointed to size of `T[][]` is `sizeof(T)`. These processes
 * interact, so the element size of a pointer to an array of `T` has an element size of `sizeof(T)`
 * and not `sizeof(T[length])`.
 */
int elementSize(Type type, Boolean deref) {
  if type instanceof ArrayType
  then result = elementSize(type.(ArrayType).getBaseType(), false)
  else
    if deref = true and type instanceof PointerType
    then result = elementSize(type.(PointerType).getBaseType(), false)
    else result = type.getSize()
}

/**
 * A pointer type casted to a byte pointer, which is effectively a pointer to a byte array whose
 * length depends on `elementSize()` of the original pointed-to type.
 */
class CastedToBytePointer extends ArrayLikeAccess, Conversion {
  /** The sizeof() the pointed-to type */
  int size;

  CastedToBytePointer() {
    getType().(PointerType).getBaseType().getSize() = 1 and
    size = elementSize(getExpr().getType(), true) and
    size > 1
  }

  override Element getElement() { result = this }

  override string getName() { result = "cast to byte pointer" }

  override int getSize() { result = size }

  override DataFlow::Node getNode() {
    // Carefully avoid use-use flow, which would mean any later usage of the original pointer value
    // after the cast would be considered a usage of the byte pointer value.
    //
    // To fix this, we currently assume the value is assigned to a variable, and find that variable
    // with `.asDefinition()` like so:
    exists(DataFlow::Node conversion |
      conversion.asConvertedExpr() = this and
      result.asDefinition() = conversion.asExpr()
    )
  }
}

predicate pointerRecastBarrier(DataFlow::Node barrier) {
  // Casting to a differently sized pointer
  exists(CStyleCast cast, Expr casted |
    cast.getExpr() = casted and casted = barrier.asConvertedExpr()
  |
    not casted.getType().(PointerType).getBaseType().getSize() =
      cast.getType().(PointerType).getBaseType().getSize()
  )
}

/**
 * A data-flow configuration that tracks access to an array to type to an array index expression.
 * This is used to determine possible pointer to array creations.
 */
module ByteArrayToArrayExprConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { exists(CastedToBytePointer a | a.getNode() = source) }

  predicate isBarrier(DataFlow::Node barrier) {
    // Casting to a differently sized pointer invalidates this analysis.
    pointerRecastBarrier(barrier)
  }

  predicate isSink(DataFlow::Node sink) { exists(ArrayExpr c | c.getArrayBase() = sink.asExpr()) }
}

module BytePointerToArrayExprFlow = DataFlow::Global<ByteArrayToArrayExprConfig>;

/**
 * A data-flow configuration that tracks access to an array to type to an array index expression.
 * This is used to determine possible pointer to array creations.
 */
module ArrayToArrayExprConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { exists(ArrayVariableAccess a | a.getNode() = source) }

  predicate isBarrier(DataFlow::Node barrier) {
    // Casting to a differently sized pointer invalidates this analysis.
    pointerRecastBarrier(barrier)
  }

  predicate isSink(DataFlow::Node sink) { exists(ArrayExpr c | c.getArrayBase() = sink.asExpr()) }
}

module ArrayToArrayExprFlow = DataFlow::Global<ArrayToArrayExprConfig>;

/** Holds if the address taken expression `addressOf` takes the address of an array element at `index` of `array`. */
predicate pointerOperandCreation(AddressOfExpr addressOf, ArrayLikeAccess array, int index) {
  exists(ArrayExpr ae, Expr arrayOffset |
    (
      ArrayToArrayExprFlow::flow(array.getNode(), DataFlow::exprNode(ae.getArrayBase())) and
      array instanceof ArrayVariableAccess
      or
      // Since casts can occur in the middle of flow, barriers are not perfect for modeling the
      // desired behavior. Handle casts to byte pointers as sources in a separate flow analysis.
      BytePointerToArrayExprFlow::flow(array.getNode(), DataFlow::exprNode(ae.getArrayBase())) and
      // flow() may hold for `ArrayVariableAccess` in the above, even though they aren't sources
      array instanceof CastedToBytePointer
    ) and
    arrayOffset = ae.getArrayOffset().getFullyConverted() and
    index = lowerBound(arrayOffset) and
    // This case typically indicates range analysis has gone wrong:
    not index = exprMaxVal(arrayOffset) and
    addressOf.getOperand() = ae
  )
}

/** A variable that points to an element of an array. */
class PointerOperand extends Variable {
  ArrayLikeAccess array;
  int index;
  AddressOfExpr source;

  PointerOperand() {
    pointerOperandCreation(source, array, index) and
    this.getAnAssignedValue() = source
  }

  ArrayLikeAccess getArray() { result = array }

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

  ArrayLikeAccess getArray() { result = operand.getArray() }

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

  ArrayLikeAccess getArray() {
    result = this.(DerivedArrayPointer).getArray() or result = this.(PointerOperand).getArray()
  }

  int getIndex() {
    result = this.(DerivedArrayPointer).getIndex() or result = this.(PointerOperand).getIndex()
  }

  Expr getSource() {
    result = this.(DerivedArrayPointer).getSource() or result = this.(PointerOperand).getSource()
  }
}

query predicate problems(Expr arrayPointerCreation, string message, Element array, string arrayName) {
  not isExcluded(arrayPointerCreation, getQuery()) and
  exists(
    DerivedArrayPointerOrPointerOperand derivedArrayPointerOrPointerOperand, int index,
    ArrayLikeAccess arrayAccess, int arraySize, int difference, string denomination
  |
    arrayAccess = derivedArrayPointerOrPointerOperand.getArray() and
    array = arrayAccess.getElement() and
    arrayName = arrayAccess.getName() and
    arraySize = arrayAccess.getSize() and
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
        difference.toString() + " " + denomination + " past the end of $@."
  )
}
