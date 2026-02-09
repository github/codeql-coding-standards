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
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p3
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Variable
import codingstandards.c.Objects
import semmle.code.cpp.models.interfaces.Allocation
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

abstract class FlexibleArrayAlloc extends Element {
  /**
   * Returns the `Variable` being allocated.
   */
  abstract Element getReportElement();
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

  override Element getReportElement() { result = v }
}

/**
 * A `Variable` of type `FlexibleArrayStructType` that is not allocated dynamically.
 */
class FlexibleArrayNonDynamicAlloc extends FlexibleArrayAlloc {
  ObjectIdentity object;

  FlexibleArrayNonDynamicAlloc() {
    this = object and
    not object.getStorageDuration().isAllocated() and
    // Exclude temporaries. Though they should violate this rule, in practice these results are
    // often spurious and redundant, such as (*x = *x) which creates an unused temporary object.
    not object.hasTemporaryLifetime() and
    object.getType().getUnspecifiedType() instanceof FlexibleArrayStructType and
    not exists(Variable v | v.getInitializer().getExpr() = this)
  }

  override Element getReportElement() { result = object }
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
select alloc, message, alloc.getReportElement(), alloc.getReportElement().toString()
