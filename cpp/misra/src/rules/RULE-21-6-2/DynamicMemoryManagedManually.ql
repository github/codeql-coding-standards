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
 * An expression that wraps `Alloc::isMemoryManagementExpr/0` and adds calls to `aligned_alloc`
 * to the set detected by it.
 */
class MemoryManagementExpr extends Expr {
  MemoryManagementExpr() {
    isMemoryManagementExpr(this) or this.(FunctionCall).getTarget() instanceof AlignedAlloc
  }
}

from Expr expr, string message
where
  not isExcluded(expr, Memory5Package::dynamicMemoryManagedManuallyQuery()) and
  (
    /* ===== 1. The expression is a use of non-placement `new`/ `new[]`, or a `delete`. ===== */
    /* ===== 2. The expression is a call to `malloc` / `calloc` / `aligned_alloc` or to `free`. ===== */
    expr instanceof MemoryManagementExpr and
    message = "This expression dynamically allocates or deallocates memory."
    or
    /* ===== 3. The expression is a call to a member function named `allocate` or `deallocate` in namespace `std`. ===== */
    exists(AllocateOrDeallocateStdlibMemberFunction allocateOrDeallocate |
      expr.(FunctionCall).getTarget() = allocateOrDeallocate and
      message =
        "This expression uses a standard library function `" +
          allocateOrDeallocate.getQualifiedName() + "` that manages memory manually."
    )
    or
    /* ===== 4. The expression is a call to `std::unique_ptr::release`. ==== */
    exists(AutosarUniquePointer uniquePtr | expr = uniquePtr.getAReleaseCall()) and
    message =
      "This expression is a call to `std::unique_ptr::release` that manages memory manually."
  )
select expr, message
