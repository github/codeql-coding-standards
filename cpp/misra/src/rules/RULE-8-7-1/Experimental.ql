/**
 * @id cpp/misra/pointer-arithmetic-forms-an-invalid-pointer
 * @name RULE-8-7-1: Pointer arithmetic shall not form an invalid pointer
 * @description Pointers obtained as result of performing arithmetic should point to an initialized
 *              object, or an element right next to the last element of an array.
 * @kind path-problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/rule-8-7-1
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.ir.dataflow.internal.DataFlowUtil
import semmle.code.cpp.security.BufferAccess

/**
 * A declaration of a variable that is of an array type.
 */
class ArrayDeclaration extends VariableDeclarationEntry {
  int length;

  ArrayDeclaration() { this.getType().getUnderlyingType().(ArrayType).getArraySize() = length }

  /**
   * Gets the declared length of this array.
   */
  int getLength() { result = length }
}

/**
 * A call to a function that dynamically allocates memory on the heap.
 */
class HeapAllocationFunctionCall extends FunctionCall {
  AllocationFunction heapAllocFunction;

  HeapAllocationFunctionCall() { this.getTarget() = heapAllocFunction }

  predicate isMallocCall() { heapAllocFunction.getName() = "malloc" }

  predicate isCallocCall() { heapAllocFunction.getName() = "calloc" }

  predicate isReallocCall() { heapAllocFunction.getName() = "realloc" }

  /**
   * Get the minimum estimated number of bytes allocated.
   */
  abstract int getMinNumBytes();
}

class MallocFunctionCall extends HeapAllocationFunctionCall {
  MallocFunctionCall() { this.isMallocCall() }

  override int getMinNumBytes() { result = lowerBound(this.getArgument(0)) }
}

class CallocFunctionCall extends HeapAllocationFunctionCall {
  CallocFunctionCall() { this.isCallocCall() }

  override int getMinNumBytes() {
    result = lowerBound(this.getArgument(0)) * lowerBound(this.getArgument(1))
  }
}

class ReallocFunctionCall extends HeapAllocationFunctionCall {
  ReallocFunctionCall() { this.isReallocCall() }

  override int getMinNumBytes() { result = lowerBound(this.getArgument(1)) }
}

/**
 * A cast that converts the pointer to an allocated byte array to that of a specialized type.
 * e.g.
 *
 * ``` C++
 * int *x = (int*)malloc(SIZE * sizeof(int));
 * ```
 * This class captures the cast `(int*)malloc(SIZE * sizeof(int))` above.
 */
class NarrowedHeapAllocationFunctionCall extends Cast {
  HeapAllocationFunctionCall alloc;

  NarrowedHeapAllocationFunctionCall() { alloc = this.getExpr() }

  int getMinNumElements() {
    exists(int rawResult |
      rawResult =
        alloc.getMinNumBytes() / this.getUnderlyingType().(PointerType).getBaseType().getSize()
    |
      /*
       * The `SimpleRangeAnalysis` library is not perfect, and sometimes can widen to both ends
       * of the type bound.
       *
       * Since it does not make sense for a object to have negative length or even zero (the
       * rule dictates that non-array objects should have length of 0), we clip the range and
       * make the minimum number of elements to 1.
       */

      result = rawResult.maximum(1)
    )
  }
}

newtype TArrayAllocation =
  TStackAllocation(ArrayDeclaration arrayDecl) or
  TDynamicAllocation(NarrowedHeapAllocationFunctionCall narrowedAlloc)

newtype TPointerFormation =
  TArrayExpr(ArrayExprBA arrayExpr) or
  TPointerArithmetic(PointerArithmeticOperation pointerArithmetic)

/**
 * Any kind of allocation of an array, either allocated on the stack or the heap.
 */
class ArrayAllocation extends TArrayAllocation {
  ArrayDeclaration asStackAllocation() { this = TStackAllocation(result) }

  NarrowedHeapAllocationFunctionCall asDynamicAllocation() { this = TDynamicAllocation(result) }

  string toString() {
    result = this.asStackAllocation().toString() or
    result = this.asDynamicAllocation().toString()
  }

  /**
   * Gets the number of the object that the array holds. This number is exact for a stack-allocated
   * array, and the minimum estimated value for a heap-allocated one.
   */
  int getLength() {
    result = this.asStackAllocation().getLength() or
    result = this.asDynamicAllocation().getMinNumElements()
  }

  Location getLocation() {
    result = this.asStackAllocation().getLocation() or
    result = this.asDynamicAllocation().getLocation()
  }

  /**
   * Gets the node associated with this allocation.
   */
  DataFlow::Node getNode() {
    result.asUninitialized() = this.asStackAllocation().getVariable() or
    result.asConvertedExpr() = this.asDynamicAllocation()
  }

  Expr asExpr() {
    result = this.asStackAllocation().getVariable().getAnAccess() or
    result = this.asDynamicAllocation()
  }
}

/**
 * Any kind of pointer formation that derives from a base pointer, either as an arithmetic operation
 * on pointers, or an array access expression.
 */
class PointerFormation extends TPointerFormation {
  ArrayExprBA asArrayExpr() { this = TArrayExpr(result) }

  PointerArithmeticOperation asPointerArithmetic() { this = TPointerArithmetic(result) }

  string toString() {
    result = this.asArrayExpr().toString() or
    result = this.asPointerArithmetic().toString()
  }

  /**
   * Gets the sub-expression of this pointer formation that corresponds to the offset.
   */
  private Expr getOffsetExpr() {
    result = this.asArrayExpr().getArrayOffset()
    or
    exists(PointerArithmeticOperation pointerArithmetic |
      pointerArithmetic = this.asPointerArithmetic()
    |
      result = pointerArithmetic.getAnOperand() // TODO: only get the number being added
    )
  }

  /**
   * Gets the offset of this pointer formation as calculated in relation to the base pointer.
   */
  int getOffset() {
    if this.asPointerArithmetic() instanceof PointerSubExpr
    then result = -this.getOffsetExpr().getValue().toInt()
    else result = this.getOffsetExpr().getValue().toInt()
  }

  /**
   * Gets the base pointer to which the offset is applied.
   */
  Expr getBase() {
    result = this.asArrayExpr().getArrayBase()
    or
    exists(PointerAddExpr pointerAddition | pointerAddition = this.asPointerArithmetic() |
      result = pointerAddition.getAnOperand() and result != this.getOffsetExpr()
    )
    or
    exists(PointerSubExpr pointerSubtraction | pointerSubtraction = this.asPointerArithmetic() |
      result = pointerSubtraction.getAnOperand() and result != this.getOffsetExpr()
    )
  }

  /**
   * Gets the expression associated with this pointer formation.
   */
  Expr asExpr() {
    result = this.asArrayExpr() or
    result = this.asPointerArithmetic()
  }

  /**
   * Gets the data-flow node associated with this pointer formation.
   */
  DataFlow::Node getNode() { result.asExpr() = this.asExpr() }

  Location getLocation() {
    result = this.asArrayExpr().getLocation() or
    result = this.asPointerArithmetic().getLocation()
  }
}

/**
 * A "fat pointer" is a pointer that is augmented with offset and length
 * information of the underlying data.
 *
 * It is either a "declared pointer" or a "index-adjusted pointer":
 * - *Allocated pointer*: a pointer is declared with a predetermined length.
 * The offset is 0.
 *   - This length info can be determined statically in some cases.
 * - *Index-adjusted pointer*: a new pointer is derived from an existing
 * fat pointer through pointer arithmetic.
 */
newtype TFatPointer =
  TAllocated(ArrayAllocation arrayDeclaration) or
  TIndexAdjusted(PointerFormation pointerFormation)

class FatPointer extends TFatPointer {
  private ArrayAllocation asAllocated() { this = TAllocated(result) }

  private PointerFormation asIndexAdjusted() { this = TIndexAdjusted(result) }

  predicate isAllocated() { exists(this.asAllocated()) }

  predicate isIndexAdjusted() { exists(this.asIndexAdjusted()) }

  /**
   * Gets the length of the underlying object, given that this fat pointer is
   * an *allocated pointer*.
   */
  int getLength() { result = this.asAllocated().getLength() }

  string toString() {
    result = this.asAllocated().toString() or
    result = this.asIndexAdjusted().toString()
  }

  Location getLocation() {
    result = this.asAllocated().getLocation() or
    result = this.asIndexAdjusted().getLocation()
  }

  int getOffset() {
    exists(this.asAllocated()) and result = 0
    or
    result = this.asIndexAdjusted().getOffset()
  }

  DataFlow::Node getNode() {
    result = this.asAllocated().getNode() or
    result = this.asIndexAdjusted().getNode()
  }

  Expr getBasePointer() {
    result = this.asAllocated().asExpr() or
    result = this.asIndexAdjusted().getBase()
  }
}

predicate srcSinkLengthMap(
  DataFlow::Node src, DataFlow::Node sink, // both `src` and `sink` are fat pointers
  int srcOffset, int sinkOffset, int length
) {
  TrackArray::flow(src, sink) and
  exists(FatPointer start, FatPointer end |
    /* Reiterate the data flow configuration here. */
    src = start.getNode() and
    sink.asExpr() = end.getBasePointer()
  |
    srcOffset = start.getOffset() and
    sinkOffset = end.getOffset() and
    (
      /* Base case: The object is allocated and a fat pointer created. */
      length = start.getLength()
      or
      /* Recursive case: A fat pointer is derived from a fat pointer. */
      srcSinkLengthMap(_, _, _, _, length)
    )
  )
}

/**
 * A data flow configuration that starts from the allocation of an array and ends at a
 * pointer derived from that array.
 */
module TrackArrayConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) {
    exists(FatPointer fatPointer | node = fatPointer.getNode())
  }

  predicate isSink(DataFlow::Node node) {
    exists(FatPointer fatPointer | node.asExpr() = fatPointer.getBasePointer())
  }
}

module TrackArray = DataFlow::Global<TrackArrayConfig>;

import TrackArray::PathGraph

from TrackArray::PathNode source, TrackArray::PathNode sink, string message
where
  not isExcluded(sink.getNode().asExpr(),
    Memory1Package::pointerArithmeticFormsAnInvalidPointerQuery()) and
  none() and // TODO
  message =
    // "This pointer has offset " + pointerOffset +
    //   " when the minimum possible length of the object might be " + arrayLength + "."
    "TODO"
select sink, source, sink, message
