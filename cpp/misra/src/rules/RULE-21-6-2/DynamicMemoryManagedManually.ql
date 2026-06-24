/**
 * @id cpp/misra/dynamic-memory-managed-manually
 * @name RULE-21-6-2: Dynamic memory shall be managed automatically
 * @description Manually allocating and deallocating is error prone and may cause memory safety bugs
 *              such as memory leaks, use-after-frees, or double frees.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-6-2
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.SmartPointers
import codingstandards.cpp.DynamicMemory
import codingstandards.cpp.allocations.CustomOperatorNewDelete

class DynamicMemoryManagementFunction extends Function {
  DynamicMemoryManagementFunction() {
    (this instanceof AllocationFunction or this instanceof AlignedAllocFunction) and
    /* Avoid duplicate alerts on `realloc` which is both an `AllocationFunction` and a `DeallocationFunction`. */
    not this instanceof ReallocFunction and
    /* Placement-new expressions are not prohibited by this rule, but by Rule 21.6.3. */
    not this instanceof PlacementOperatorNew
    or
    this instanceof DeallocationFunction and
    /* Avoid duplicate alerts on `realloc` which is both an `AllocationFunction` and a `DeallocationFunction`. */
    not this instanceof ReallocFunction
    or
    this instanceof ReallocFunction
    or
    this instanceof AllocateOrDeallocateStdlibMemberFunction
    or
    this instanceof UniquePointerReleaseFunction
  }
}

/**
 * The `std::realloc` (`<cstdlib>`) or `::realloc` (`<stdlib.h>`) function.
 */
class ReallocFunction extends Function {
  ReallocFunction() { this.hasGlobalOrStdName("realloc") }
}

/**
 * The `std::aligned_alloc` (`<cstdlib>`) or `::aligned_alloc` (`<stdlib.h>`) function.
 */
class AlignedAllocFunction extends Function {
  AlignedAllocFunction() { this.hasGlobalOrStdName("aligned_alloc") }
}

/**
 * The `std::unique_ptr::release` member function.
 */
class UniquePointerReleaseFunction extends MemberFunction {
  UniquePointerReleaseFunction() { this.getClassAndName("release") instanceof AutosarUniquePointer }
}

from Expr expr, string message
where
  not isExcluded(expr, Memory5Package::dynamicMemoryManagedManuallyQuery()) and
  exists(DynamicMemoryManagementFunction dynamicMemoryManagementFunction |
    /* ===== 1. The expression calls one of the dynamic memory management functions. ===== */
    expr = dynamicMemoryManagementFunction.getACallToThisFunction() and
    message = "Banned call to `" + dynamicMemoryManagementFunction.getQualifiedName() + "`."
    or
    /* ===== 2. The expression takes address of the dynamic memory management functions. ===== */
    expr = dynamicMemoryManagementFunction.getAnAccess() and
    message =
      "Taking the address of banned `" + dynamicMemoryManagementFunction.getQualifiedName() + "`."
  )
select expr, message
