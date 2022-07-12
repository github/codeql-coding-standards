#include <new>

void *operator new(std::size_t size) {
  if (size > 10000) {
    throw std::bad_alloc{}; // COMPLIANT
  } else if (size < 0) {
    throw "error!"; // NON_COMPLIANT
  }
}

void *operator new[](std::size_t size) {
  if (size > 10000) {
    throw std::bad_alloc{}; // COMPLIANT
  } else if (size < 0) {
    throw "error!"; // NON_COMPLIANT
  }
}