/**
 * @id cpp/misra/pointer-arithmetic-forms-an-invalid-pointer
 * @name RULE-8-7-1: Pointer arithmetic shall not form an invalid pointer.
 * @description Pointers obtained as result of performing arithmetic should point to an initialized
 *              object, or an element right next to the last element of an array.
 * @kind path-problem
 * @precision very-high
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
private import semmle.code.cpp.ir.IR // For PointerArithmeticInstruction (see TrackArray::isAdditionalFlowStep/2 below)
private import semmle.code.cpp.ir.dataflow.internal.DataFlowPrivate // For PointerArithmeticInstruction (see TrackArray::isAdditionalFlowStep/2 below)
private import semmle.code.cpp.ir.dataflow.internal.DataFlowUtil // For PointerArithmeticInstruction (see TrackArray::isAdditionalFlowStep/2 below)
private import semmle.code.cpp.ir.dataflow.FlowSteps // For PointerArithmeticInstruction (see TrackArray::isAdditionalFlowStep/2 below)
private import semmle.code.cpp.ir.dataflow.internal.SsaInternals as Ssa

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

class HeapAllocationFunctionCall extends FunctionCall {
  AllocationFunction heapAllocFunction;

  HeapAllocationFunctionCall() { this.getTarget() = heapAllocFunction }

  predicate isMallocCall() { heapAllocFunction.getName() = "malloc" }

  predicate isCallocCall() { heapAllocFunction.getName() = "calloc" }

  predicate isReallocCall() { heapAllocFunction.getName() = "realloc" }

  abstract Expr getByteArgument();

  int getByteLowerBound() { result = lowerBound(this.getByteArgument()) }
}

class MallocFunctionCall extends HeapAllocationFunctionCall {
  MallocFunctionCall() { this.isMallocCall() }

  override Expr getByteArgument() { result = this.getArgument(0) }
}

class CallocReallocFunctionCall extends HeapAllocationFunctionCall {
  CallocReallocFunctionCall() { this.isCallocCall() or this.isReallocCall() }

  override Expr getByteArgument() { result = this.getArgument(1) }
}

class NarrowedHeapAllocationFunctionCall extends Cast {
  HeapAllocationFunctionCall alloc;

  NarrowedHeapAllocationFunctionCall() { alloc = this.getExpr() }

  int getMinNumElements() {
    result =
      alloc.getByteLowerBound() / this.getUnderlyingType().(PointerType).getBaseType().getSize()
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
    result.asExpr() = this.asStackAllocation().getInitExpr() or
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
    result = this.asArrayExpr() or // This needs to be array base, as we are only dealing with pointers here.
    result = this.asPointerArithmetic()
  }

  DataFlow::Node getNode() { result.asExpr() = this.asExpr() }

  Location getLocation() {
    result = this.asArrayExpr().getLocation() or
    result = this.asPointerArithmetic().getLocation()
  }
}

/**
 * NOTE
 */
private predicate operandToInstructionTaintStep(Operand opFrom, Instruction instrTo) {
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

module TrackArrayConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) {
    exists(ArrayAllocation arrayAllocation | node = arrayAllocation.getNode())
  }

  predicate isSink(DataFlow::Node node) {
    exists(PointerFormation pointerFormation | node = pointerFormation.getNode())
  }

  predicate isAdditionalFlowStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    /*
     * NOTE
     */

    operandToInstructionTaintStep(nodeFrom.asOperand(), nodeTo.asInstruction())
    or
    exists(PointerArithmeticInstruction pai, int indirectionIndex |
      nodeHasOperand(nodeFrom, pai.getAnOperand(), pragma[only_bind_into](indirectionIndex)) and
      hasInstructionAndIndex(nodeTo, pai, indirectionIndex + 1)
    )
  }
}

module TrackArray = DataFlow::Global<TrackArrayConfig>;

private predicate arrayIndexExceedsOutOfBounds(
  DataFlow::Node arrayDeclarationNode, DataFlow::Node pointerFormationNode
) {
  /* 1. Ensure the array access is reachable from the array declaration. */
  TrackArray::flow(arrayDeclarationNode, pointerFormationNode) and
  /* 2. Cases where a pointer formation becomes illegal. */
  exists(ArrayAllocation arrayAllocation, PointerFormation pointerFormation |
    arrayDeclarationNode = arrayAllocation.getNode() and
    pointerFormationNode = pointerFormation.getNode()
  |
    /* 2-1. An offset cannot be negative. */
    pointerFormation.getOffset() < 0
    or
    /* 2-2. The offset should be at most (number of elements) + 1 = (the declared length). */
    arrayAllocation.getLength() < pointerFormation.getOffset()
  )
}

import TrackArray::PathGraph

from TrackArray::PathNode source, TrackArray::PathNode sink
where
  not isExcluded(sink.getNode().asExpr(),
    Memory1Package::pointerArithmeticFormsAnInvalidPointerQuery()) and
  arrayIndexExceedsOutOfBounds(source.getNode(), sink.getNode())
select sink, source, sink, "TODO"
