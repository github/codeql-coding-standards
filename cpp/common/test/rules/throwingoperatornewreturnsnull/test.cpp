#include <new>

void *can_return_null(std::size_t size) {
  return ::operator new(size, std::nothrow);
}

void *operator new(std::size_t size) {
  void *localVariable{}; // zero-initialized
  if (size < 10) {
    return localVariable; // NON_COMPLIANT
  } else if (size < 100) {
    return nullptr; // NON_COMPLIANT
  } else {
    return can_return_null(size); // NON_COMPLIANT
  }
}