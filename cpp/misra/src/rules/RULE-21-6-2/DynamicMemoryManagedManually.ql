/**
 * @id cpp/misra/dynamic-memory-managed-manually
 * @name RULE-21-6-2: Dynamic memory shall be managed automatically
 * @description Dynamically allocated memory must not be managed manually.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-6-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.SmartPointers

/**
 * An `operator new` or `operator new[]` allocation function called by a placement-new expression.
 *
 * The operator functions are supposed to have a `std::size_t` as their first parameter and a
 * `void*` parameter somewhere in the rest of the parameter list.
 */
class PlacementNewOrNewArrayAllocationFunction extends AllocationFunction {
  PlacementNewOrNewArrayAllocationFunction() {
    this.getName() in ["operator new", "operator new[]"] and
    this.getParameter(0).getType().resolveTypedefs*() instanceof Size_t and
    this.getAParameter().getUnderlyingType() instanceof VoidPointerType
  }
}

class DynamicMemoryManagementFunction extends Function {
  string description;

  DynamicMemoryManagementFunction() {
    (
      (this instanceof AllocationFunction or this instanceof AlignedAlloc) and
      /* Placement-new expressions are not prohibited by this rule, but by Rule 21.6.3. */
      not this instanceof PlacementNewOrNewArrayAllocationFunction
    ) and
    description = "an expression that dynamically allocates memory"
    or
    this instanceof DeallocationFunction and
    description = "an expression that dynamically deallocates memory"
    or
    this instanceof AllocateOrDeallocateStdlibMemberFunction and
    description = "a standard library function that manages memory manually"
    or
    this instanceof UniquePointerReleaseFunction and
    description = "`std::unique_ptr::release`"
  }

  string describe() { result = description }
}

/**
 * A function that has namespace `std` and has name `allocate` or `deallocate`, including but not limited to:
 * - `std::allocator<T>::allocate(std::size_t)`
 * - `std::allocator<T>::dellocate(T*, std::size_t)`
 * - `std::pmr::memory_resource::allocate(std::size_t, std::size_t)`
 * - `std::pmr::memory_resource::allocate(std::size_t, std::size_t)`
 */
class AllocateOrDeallocateStdlibMemberFunction extends MemberFunction {
  AllocateOrDeallocateStdlibMemberFunction() {
    this.getName() in ["allocate", "deallocate"] and
    this.getNamespace().getParentNamespace*() instanceof StdNamespace
  }
}

/**
 * The `std::aligned_alloc` (`<cstdlib>`) or `::aligned_alloc` (`<stdlib.h>`) function.
 */
class AlignedAlloc extends Function {
  AlignedAlloc() { this.hasGlobalOrStdName("aligned_alloc") }
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
    message =
      "This expression is a call to `" + dynamicMemoryManagementFunction.getName() + "` which is " +
        dynamicMemoryManagementFunction.describe() + "."
    or
    /* ===== 2. The expression takes address of the dynamic memory management functions. ===== */
    expr = dynamicMemoryManagementFunction.getAnAccess() and
    message =
      "This expression takes address of `" + dynamicMemoryManagementFunction.getName() +
        "` which is " + dynamicMemoryManagementFunction.describe() + "."
  )
select expr, message
