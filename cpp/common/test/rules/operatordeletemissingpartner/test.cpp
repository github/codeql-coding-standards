#include <new>

// clang-format off
void operator delete(void *ptr) noexcept {} // NON_COMPLIANT
// void operator delete(void* ptr, std::size_t size) noexcept;

// void operator delete(void*, const std::nothrow_t&)
void operator delete(void *, std::size_t, const std::nothrow_t &) {} // NON_COMPLIANT

void operator delete[](void *) {} // NON_COMPLIANT
// operator delete[](void*, std::size_t)

void operator delete[](void *, const std::nothrow_t &) {} // COMPLIANT
void operator delete[](void *, std::size_t, const std::nothrow_t &) {} // COMPLIANT
// clang-format on