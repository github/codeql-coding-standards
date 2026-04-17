/** Provides classes for modeling dynamic memory allocation and deallocation functions. */

import cpp

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
