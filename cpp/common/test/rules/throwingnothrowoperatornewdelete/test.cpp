#include <new>

/*
 * We can't declare multiple versions of these functions in the same test case,
 * so we provide some with and without throws.
 */

void *operator new(std::size_t) {
  throw std::bad_alloc{}; // COMPLIANT - not a nothrow
}
void *operator new(std::size_t, const std::nothrow_t &) {
  throw std::bad_alloc{}; // NON_COMPLIANT
}
void *operator new[](std::size_t) {
  throw std::bad_alloc{}; // COMPLIANT - not a nothrow
}
void *operator new[](std::size_t, const std::nothrow_t &) {} // COMPLIANT
void operator delete(void *) {
  throw std::bad_alloc{}; // COMPLIANT - not a nothrow
}
void operator delete(void *, std::size_t) {
  throw std::bad_alloc{}; // COMPLIANT - not a nothrow
}
void operator delete(void *, const std::nothrow_t &) {} // COMPLIANT
void operator delete(void *, std::size_t, const std::nothrow_t &) {
  throw std::bad_alloc{}; // NON_COMPLIANT
}
void operator delete[](void *) {
  throw std::bad_alloc{}; // COMPLIANT - not a nothrow
}
void operator delete[](void *, std::size_t) {
  throw std::bad_alloc{}; // COMPLIANT - not a nothrow
}
void operator delete[](void *, const std::nothrow_t &) {} // COMPLIANT
void operator delete[](void *, std::size_t, const std::nothrow_t &) {
  throw std::bad_alloc{}; // NON_COMPLIANT
}