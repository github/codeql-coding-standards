/**
 * @id c/cert/alloc-structs-with-a-flexible-array-member-dynamically
 * @name MEM33-C: Allocate structures containing a flexible array member dynamically
 * @description A structure containing a flexible array member must be allocated dynamically in
 *              order for subsequent accesses to the flexible array to point to valid memory.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/mem33-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Variable
import semmle.code.cpp.models.interfaces.Allocation
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

abstract class FlexibleArrayAlloc extends Element {
  /**
   * Returns the `Variable` being allocated.
   */
  abstract Variable getVariable();
}

/**
 * A `FunctionCall` to an `AllocationFunction` that allocates memory
 * which is assigned to a `Variable` of type `FlexibleArrayStructType`.
 */
class FlexibleArrayStructDynamicAlloc extends FlexibleArrayAlloc, FunctionCall {
  Variable v;

  FlexibleArrayStructDynamicAlloc() {
    this.getTarget() instanceof AllocationFunction and
    v.getAnAssignedValue() = this and
    v.getUnderlyingType().(PointerType).getBaseType().getUnspecifiedType() instanceof
      FlexibleArrayStructType
  }

  /**
   * Holds if the size argument of the allocation function is insufficient to
   * allocate at least one byte for the flexible array member.
   */
  predicate hasInsufficientAllocationSize() {
    upperBound(this.getArgument(this.getTarget().(AllocationFunction).getSizeArg())) <=
      max(v.getUnderlyingType()
              .(PointerType)
              .getBaseType()
              .getUnspecifiedType()
              .(FlexibleArrayStructType)
              .getSize()
      )
  }

  override Variable getVariable() { result = v }
}

/**
 * A `Variable` of type `FlexibleArrayStructType` that is not allocated dynamically.
 */
class FlexibleArrayNonDynamicAlloc extends FlexibleArrayAlloc, Variable {
  FlexibleArrayNonDynamicAlloc() {
    this.getUnspecifiedType().getUnspecifiedType() instanceof FlexibleArrayStructType
  }

  override Variable getVariable() { result = this }
}

from FlexibleArrayAlloc alloc, string message
where
  not isExcluded(alloc, Memory2Package::allocStructsWithAFlexibleArrayMemberDynamicallyQuery()) and
  (
    alloc.(FlexibleArrayStructDynamicAlloc).hasInsufficientAllocationSize() and
    message = "$@ allocated with insufficient memory for its flexible array member."
    or
    alloc instanceof FlexibleArrayNonDynamicAlloc and
    message = "$@ contains a flexible array member but is not dynamically allocated."
  )
select alloc, message, alloc.getVariable(), alloc.getVariable().getName()
