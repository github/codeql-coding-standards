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
  DynamicMemoryManagementFunction() {
    (this instanceof AllocationFunction or this instanceof AlignedAllocFunction) and
    /* Avoid duplicate alerts on `realloc` which is both an `AllocationFunction` and a `DeallocationFunction`. */
    not this instanceof ReallocFunction and
    /* Placement-new expressions are not prohibited by this rule, but by Rule 21.6.3. */
    not this instanceof PlacementNewOrNewArrayAllocationFunction
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
 * A function that has namespace `std` and has name `allocate` or `deallocate`, including but not limited to:
 * - `std::allocator<T>::allocate(std::size_t)`
 * - `std::allocator<T>::dellocate(T*, std::size_t)`
 * - `std::pmr::memory_resource::allocate(std::size_t, std::size_t)`
 * - `std::pmr::memory_resource::deallocate(void*, std::size_t, std::size_t)`
 */
class AllocateOrDeallocateStdlibMemberFunction extends MemberFunction {
  AllocateOrDeallocateStdlibMemberFunction() {
    this.getName() in ["allocate", "deallocate"] and
    this.getNamespace().getParentNamespace*() instanceof StdNamespace
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
      "Taking the address of banned `" +
        dynamicMemoryManagementFunction.getQualifiedName() + "`."
  )
select expr, message
