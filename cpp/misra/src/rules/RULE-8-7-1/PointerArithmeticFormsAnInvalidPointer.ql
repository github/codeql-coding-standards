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
import semmle.code.cpp.dataflow.new.TaintTracking
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
 * The
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
    // int x[4];
    //result.asExpr() = this.asStackAllocation().getVariable().getInitializer().getExpr()

    // void f(int *ptr[4]) {
    //   *ptr + 5; // NON_COMPLIANT
    //}
    exists(ArrayToPointerConversion arrayToPointer |
      arrayToPointer.getExpr() = this.asStackAllocation().getVariable().getAnAccess() and
      result.asConvertedExpr() = arrayToPointer
    )
    //result.asVariable() = this.asStackAllocation().getVariable()
    //result.asConvertedExpr() = this.asDynamicAllocation()
  }
}

//predicate isArrayAccess(ArrayExpr ae, Type t, int cval) {
//  t = ae.getArrayBase().getUnderlyingType() and
//  cval = ae.getArrayOffset().getValue().toInt()
//}
predicate isBadArrayAccess(ArrayExpr ae) {
  // x[y]
  // x has type int[4]
  ae.getArrayBase().getUnderlyingType().(ArrayType).getArraySize() <= ae.getArrayOffset().getValue().toInt()
}

predicate isDecaySource(DataFlow::Node node, int arraySize) {
  // x[4];
  // f(x); // x decays to int*
  // x + 2; // x decays to int*
  exists(ArrayToPointerConversion atpc |
    node.asConvertedExpr() = atpc and
    arraySize = atpc.getExpr().getUnderlyingType().(ArrayType).getArraySize()
  )
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
   * Gets the offset of this pointer formation as calculated in relation to the base pointer.
   */
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

  /**
   * Gets the expression associated with this pointer formation.
   */
  Expr asExpr() {
    result = this.asArrayExpr() or
    result = this.asPointerArithmetic()
  }

  Expr getPointerBase() {
    result = this.asArrayExpr().getArrayBase()
    or
    result = this.asPointerArithmetic().getAnOperand()
  }

  // getNode() = arr[x] or ptr + n
  // getNode() = arr or ptr
  DataFlow::Node getPointerNode() { result.asExpr() = this.getPointerBase() }
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
 * NOTE The code in the below module is copied from
 * `cpp/ql/lib/semmle/code/cpp/ir/dataflow/internal/TaintTrackingUtil.qll` in `github/codeql`, commit hash
 * `960e990`. This commit hash is the latest of the ones with tag  `codeql-cli-2.21.4` which is the CLI version
 * compatible with `codeql/cpp-all: 5.0.0` that this query depends on.
 */
module Copied {
  import semmle.code.cpp.ir.IR
  import semmle.code.cpp.ir.dataflow.internal.SsaInternals as Ssa

  predicate operandToInstructionTaintStep(Operand opFrom, Instruction instrTo) {
    // Taint can flow through expressions that alter the value but preserve
    // more than one bit of it _or_ expressions that follow data through
    // pointer indirections.
    instrTo.getAnOperand() = opFrom and
    (
      instrTo instanceof ArithmeticInstruction
      or
      instrTo instanceof BitwiseInstruction
      or
      instrTo instanceof PointerArithmeticInstruction
    )
    or
    // Taint flow from an address to its dereference.
    Ssa::isDereference(instrTo, opFrom, _)
    or
    // Unary instructions tend to preserve enough information in practice that we
    // want taint to flow through.
    // The exception is `FieldAddressInstruction`. Together with the rules below for
    // `LoadInstruction`s and `ChiInstruction`s, flow through `FieldAddressInstruction`
    // could cause flow into one field to come out an unrelated field.
    // This would happen across function boundaries, where the IR would not be able to
    // match loads to stores.
    instrTo.(UnaryInstruction).getUnaryOperand() = opFrom and
    (
      not instrTo instanceof FieldAddressInstruction
      or
      instrTo.(FieldAddressInstruction).getField().getDeclaringType() instanceof Union
    )
    or
    // Taint from int to boolean casts. This ensures that we have flow to `!x` in:
    // ```cpp
    // x = integer_source();
    // if(!x) { ... }
    // ```
    exists(Operand zero |
      zero.getDef().(ConstantValueInstruction).getValue() = "0" and
      instrTo.(CompareNEInstruction).hasOperands(opFrom, zero)
    )
  }
}

import Copied

/**
 * A data flow configuration that starts from the allocation of an array and ends at a
 * pointer derived from that array.
 */
module TrackArrayConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) {
    exists(ArrayAllocation arrayAllocation | node = arrayAllocation.getNode())
    //node.asConvertedExpr() instanceof ArrayToPointerConversion
  }

  predicate isSink(DataFlow::Node node) {
    //exists(PointerFormation pointerFormation | node = pointerFormation.getNode())
    exists(PointerFormation pointerFormation | node = pointerFormation.getPointerNode())
  }

  predicate isAdditionalFlowStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    //operandToInstructionTaintStep(nodeFrom.asOperand(), nodeTo.asInstruction()) and
    //nodeTo.asInstruction() instanceof PointerArithmeticInstruction
    //exists(ArrayToPointerConversion arrayToPointer |
    //  nodeFrom.asExpr() = arrayToPointer and
    //  nodeTo.asExpr() = arrayToPointer
    //)
    none()
  }
}

int length() { result = 20 }

  module TrackArrayFwd = TrackArray::FlowExplorationFwd<length/0>;

  predicate trackArrayDebug(TrackArrayFwd::PartialPathNode source) {
      TrackArrayFwd::partialFlow(source, _, _)
  }

module TrackArray = DataFlow::Global<TrackArrayConfig>;

/**
 * Holds if the offset of a pointer formation, as referred to by `pointerFormationNode`,
 * exceeds the length of the declared array, as represented by `arrayDeclarationNode`.
 */
predicate arrayIndexExceedsBounds(
  DataFlow::Node arrayDeclarationNode, DataFlow::Node pointerFormationNode, int pointerOffset,
  int arrayLength
) {
  /* 1. Ensure the array access is reachable from the array declaration. */
  TrackArray::flow(arrayDeclarationNode, pointerFormationNode) and
  /* 2. The offset must be at most (number of elements) + 1 = (the declared length). */
  exists(ArrayAllocation arrayAllocation, PointerFormation pointerFormation |
    arrayDeclarationNode = arrayAllocation.getNode() and
    pointerFormationNode = pointerFormation.getPointerNode() and
    pointerOffset = pointerFormation.getOffset() and
    arrayLength = arrayAllocation.getLength()
  |
    arrayLength < pointerOffset
  )
}

import TrackArray::PathGraph

from TrackArray::PathNode source, TrackArray::PathNode sink, string message
where
  not isExcluded(sink.getNode().asExpr(),
    Memory1Package::pointerArithmeticFormsAnInvalidPointerQuery()) and
  exists(int pointerOffset, int arrayLength |
    arrayIndexExceedsBounds(source.getNode(), sink.getNode(), pointerOffset, arrayLength) and
    message =
      "This pointer has offset " + pointerOffset +
        " when the minimum possible length of the object might be " + arrayLength + "."
  )
select sink, source, sink, message

//import codingstandards.cpp.OutOfBounds
//
//from
//    Expr bufferArg, Expr sizeArg, OOB::PointerToObjectSource bufferSource, int computedBufferSize,
//    int computedSizeAccessed, BufferAccess bufferAccess
//where
// OOB::isSizeArgGreaterThanBufferSize(bufferArg, sizeArg, bufferSource, computedBufferSize,
//    computedSizeAccessed, bufferAccess)
//select bufferArg