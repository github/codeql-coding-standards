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
import semmle.code.cpp.ir.IR
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

  int getLength(int indirection) { result = getArrayType(indirection).getArraySize() }

  private ArrayType getArrayType(int indirection) {
    indirection = 0 and result = this.getType().getUnderlyingType()
    or
    exists(ArrayType at |
      at = getArrayType(indirection - 1) and
      result = at.getBaseType().getUnderlyingType()
    )
  }
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
  int getLength(DataFlow::Node node) {
    exists(IndirectUninitializedNode inode |
      inode = node and
      inode.getLocalVariable() = this.asStackAllocation().getVariable() and
      result = this.asStackAllocation().getLength(inode.getIndirection())
    )
    or
    result = this.asStackAllocation().getLength() and
    node.asUninitialized() = this.asStackAllocation().getVariable()
    or
    result = this.asDynamicAllocation().getMinNumElements() and
    node.asConvertedExpr() = this.asDynamicAllocation()
  }

  Location getLocation() {
    result = this.asStackAllocation().getLocation() or
    result = this.asDynamicAllocation().getLocation()
  }

  /**
   * Gets the node associated with this allocation.
   */
  DataFlow::Node getNode() { exists(getLength(result)) }

  Expr asExpr() {
    result = this.asStackAllocation().getVariable().getAnAccess() or
    result = this.asDynamicAllocation()
  }
}

/*
 * NOTE: `IndirectUninitializedNode` has made its way into `github/codeql`. Once we upgrade it to
 * the version that has it, the class can be safely removed.
 */

import semmle.code.cpp.ir.dataflow.internal.SsaInternals as SsaImpl

class IndirectUninitializedNode extends Node {
  LocalVariable v;
  int indirection;

  IndirectUninitializedNode() {
    exists(SsaImpl::Definition def, SsaImpl::SourceVariable sv |
      def.getIndirectionIndex() = indirection and
      indirection > 0 and
      def.getValue().asInstruction() instanceof UninitializedInstruction and
      SsaImpl::defToNode(this, def, sv) and
      v = sv.getBaseVariable().(SsaImpl::BaseIRVariable).getIRVariable().getAst()
    )
  }

  /** Gets the uninitialized local variable corresponding to this node. */
  LocalVariable getLocalVariable() { result = v }

  int getIndirection() { result = indirection }
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

  DataFlow::Node getBaseNode() { result.asIndirectExpr() = this.getBase() }

  /**
   * Gets the expression associated with this pointer formation.
   */
  Expr asExpr() {
    result = this.asArrayExpr() or
    result = this.asPointerArithmetic()
  }

  private PointerAddInstruction getInstruction() { result.getAst() = this.asExpr() }

  /**
   * Gets the data-flow node associated with this pointer formation.
   */
  DataFlow::Node getNode() { result.asInstruction() = getInstruction() }

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
  ArrayAllocation asAllocated() { this = TAllocated(result) }

  PointerFormation asIndexAdjusted() { this = TIndexAdjusted(result) }

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

  DataFlow::Node getBasePointerNode() {
    result = this.asIndexAdjusted().getBaseNode()
    or
    exists(PointerAddInstruction ptrAdd |
      result.asInstruction() = ptrAdd.getAnOperand().getDef() and
      (
        result.asInstruction().getAst() = this.asIndexAdjusted().getBase() or
        result.asInstruction().getAst() = this.asAllocated().asExpr()
      )
    )
    or
    exists(PointerSubInstruction ptrSub |
      result.asInstruction() = ptrSub.getAnOperand().getDef() and
      (
        result.asInstruction().getAst() = this.asIndexAdjusted().getBase() or
        result.asInstruction().getAst() = this.asAllocated().asExpr()
      )
    )
  }
}

/**
 * A table with headers (start pointer, end pointer, source offset, sink offset, length).
 * Consider the following code:
 * ``` C++
 *   int buf[10];
 *   int *p = buf;
 *   int *p2 = p - 5;
 *   int *p3 = p2 + 16;
 * ```
 * Then, this table is roughly populated with:
 * |-------------+----------------+------------+-------------+----------------+------------------|
 * | flow start  | flow end       | src offset | sink offset | length(exists) | valid?           |
 * |-------------+----------------+------------+-------------+----------------+------------------|
 * | int buf[10] | p  (∵ p - 5)   |          0 |          -5 |             10 | No,  0-5 < 10    |
 * | p           | p2 (∵ p2 + 12) |         -5 |          12 |             10 | Yes, -5+12 < 10  |
 * |-------------+----------------+------------+-------------+----------------+------------------|
 *
 * And then we can answer the question of whether the pointer is valid (last column `valid?`).
 * NOTE: Consult the configuration `TrackArrayConfig` for the actual definition of `src` and `sink`.
 */
predicate srcSinkLengthMap(
  FatPointer start, FatPointer end, int srcOffset, int sinkOffset, int length
) {
  exists(TrackArray::PathNode src, TrackArray::PathNode sink |
    TrackArray::flowPath(src, sink) and
    /* Reiterate the data flow configuration here. */
    src.getNode() = start.getNode() and
    sink.getNode() = end.getBasePointerNode()
  |
    srcOffset = start.getOffset() and
    sinkOffset = end.getOffset() and
    (
      /* Base case: The object is allocated and a fat pointer created. */
      length = start.asAllocated().getLength(src.getNode())
      or
      /* Recursive case: A fat pointer is derived from a fat pointer. */
      srcSinkLengthMap(_, start, _, srcOffset, length)
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
    exists(FatPointer fatPointer | node = fatPointer.getBasePointerNode())
  }
}

module TrackArray = DataFlow::Global<TrackArrayConfig>;

import TrackArray::PathGraph

from
  TrackArray::PathNode src, TrackArray::PathNode sink, FatPointer end, int totalOffset, int length
where
  not isExcluded(sink.getNode().asExpr(),
    Memory1Package::pointerArithmeticFormsAnInvalidPointerQuery()) and
  exists(FatPointer start, int srcOffset, int sinkOffset |
    src.getNode() = start.getNode() and
    sink.getNode() = end.getBasePointerNode()
  |
    srcSinkLengthMap(start, end, srcOffset, sinkOffset, length) and
    totalOffset = srcOffset + sinkOffset and
    (
      totalOffset < 0 or // Underflow detection
      totalOffset > length // Overflow detection
    )
  )
select end, src, sink,
  "This pointer accesses element at index " + totalOffset +
    " while the underlying object has length " + length + "."
