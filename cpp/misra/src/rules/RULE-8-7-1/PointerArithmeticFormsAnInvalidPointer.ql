/**
 * @id cpp/misra/pointer-arithmetic-forms-an-invalid-pointer
 * @name RULE-8-7-1: Pointer arithmetic shall not form an invalid pointer.
 * @description Pointers obtained as result of performing arithmetic should point to an initialized
 *              object, or an element right next to the last element of an array.
 * @kind path-problem
 * @precision high
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

class ArrayDeclaration extends VariableDeclarationEntry {
  int length;

  ArrayDeclaration() { this.getType().getUnderlyingType().(ArrayType).getArraySize() = length }

  /**
   * Gets the declared length of this array.
   */
  int getLength() { result = length }
}

class HeapAllocationFunctionCall extends FunctionCall {
  AllocationFunction heapAllocFunction;

  HeapAllocationFunctionCall() { this.getTarget() = heapAllocFunction }

  predicate isMallocCall() { heapAllocFunction.getName() = "malloc" }

  predicate isCallocCall() { heapAllocFunction.getName() = "calloc" }

  predicate isReallocCall() { heapAllocFunction.getName() = "realloc" }

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

class NarrowedHeapAllocationFunctionCall extends Cast {
  HeapAllocationFunctionCall alloc;

  NarrowedHeapAllocationFunctionCall() { alloc = this.getExpr() }

  int getMinNumElements() {
    result = alloc.getMinNumBytes() / this.getUnderlyingType().(PointerType).getBaseType().getSize()
  }

  HeapAllocationFunctionCall getAllocFunctionCall() { result = alloc }
}

newtype TArrayAllocation =
  TStackAllocation(ArrayDeclaration arrayDecl) or
  TDynamicAllocation(NarrowedHeapAllocationFunctionCall narrowedAlloc)

newtype TPointerFormation =
  TArrayExpr(ArrayExprBA arrayExpr) or
  TPointerArithmetic(PointerArithmeticOperation pointerArithmetic)

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

  DataFlow::Node getNode() {
    result.asUninitialized() = this.asStackAllocation().getVariable() or
    result.asConvertedExpr() = this.asDynamicAllocation()
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
    /*.getArrayBase()*/ result = this.asPointerArithmetic()
  }

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

module TrackArrayConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) {
    exists(ArrayAllocation arrayAllocation | node = arrayAllocation.getNode())
  }

  predicate isSink(DataFlow::Node node) {
    exists(PointerFormation pointerFormation | node = pointerFormation.getNode())
  }

  predicate isAdditionalFlowStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    operandToInstructionTaintStep(nodeFrom.asOperand(), nodeTo.asInstruction())
  }
}

module TrackArray = DataFlow::Global<TrackArrayConfig>;

predicate arrayIndexIsNegative(
  DataFlow::Node arrayDeclarationNode, DataFlow::Node pointerFormationNode
) {
  /* 1. Ensure the array access is reachable from the array declaration. */
  TrackArray::flow(arrayDeclarationNode, pointerFormationNode) and
  /* 2. An offset cannot be negative. */
  exists(ArrayAllocation arrayAllocation, PointerFormation pointerFormation |
    arrayDeclarationNode = arrayAllocation.getNode() and
    pointerFormationNode = pointerFormation.getNode()
  |
    pointerFormation.getOffset() < 0
  )
}

predicate arrayIndexExceedsBounds(
  DataFlow::Node arrayDeclarationNode, DataFlow::Node pointerFormationNode, int pointerOffset,
  int arrayLength
) {
  /* 1. Ensure the array access is reachable from the array declaration. */
  TrackArray::flow(arrayDeclarationNode, pointerFormationNode) and
  /* 2. The offset must be at most (number of elements) + 1 = (the declared length). */
  exists(ArrayAllocation arrayAllocation, PointerFormation pointerFormation |
    arrayDeclarationNode = arrayAllocation.getNode() and
    pointerFormationNode = pointerFormation.getNode() and
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
  (
    exists(int pointerOffset, int arrayLength |
      arrayIndexExceedsBounds(source.getNode(), sink.getNode(), pointerOffset, arrayLength) and
      message =
        "This pointer has offset " + pointerOffset +
          " when the minimum possible length of the object is " + arrayLength + "."
    )
    or
    arrayIndexIsNegative(source.getNode(), sink.getNode()) and
    message = "This pointer has a negative offset."
  )
select sink, source, sink, message
