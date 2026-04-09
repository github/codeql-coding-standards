/** Provides classes for modeling dynamic memory allocation and deallocation functions. */

import cpp

/**
 * An `operator new` or `operator new[]` allocation function called by a placement-new expression.
 *
 * The operator functions have a `std::size_t` as their first parameter and a
 * `void*` parameter somewhere in the rest of the parameter list.
 */
class PlacementNewOrNewArrayAllocationFunction extends AllocationFunction {
  PlacementNewOrNewArrayAllocationFunction() {
    this.getName() in ["operator new", "operator new[]"] and
    this.getParameter(0).getType().resolveTypedefs*() instanceof Size_t and
    this.getAParameter().getUnderlyingType() instanceof VoidPointerType
  }
}

/**
 * A function that has namespace `std` and has name `allocate` or `deallocate`, including but
 * not limited to:
 * - `std::allocator<T>::allocate(std::size_t)`
 * - `std::allocator<T>::deallocate(T*, std::size_t)`
 * - `std::pmr::memory_resource::allocate(std::size_t, std::size_t)`
 * - `std::pmr::memory_resource::deallocate(void*, std::size_t, std::size_t)`
 */
class AllocateOrDeallocateStdlibMemberFunction extends MemberFunction {
  AllocateOrDeallocateStdlibMemberFunction() {
    this.getName() in ["allocate", "deallocate"] and
    this.getNamespace().getParentNamespace*() instanceof StdNamespace
  }
}
