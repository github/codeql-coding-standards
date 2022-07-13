#include <stddef.h>

void *operator new(size_t) noexcept(false) { // NON_COMPLIANT
}

void operator delete[](void *) { // NON_COMPLIANT
}

struct S1 {
  void *operator new(size_t) noexcept(false) {} // COMPLIANT

  void operator delete(void *) {} // COMPLIANT

  void *operator new[](size_t) noexcept(false) {} // COMPLIANT

  void operator delete[](void *) {} // COMPLIANT
};

struct S2 {
  void *operator new(size_t) noexcept(false) {}   // NON_COMPLIANT
  void *operator new[](size_t) noexcept(false) {} // NON_COMPLIANT
};

struct S3 {
  void *operator new(size_t, void *) noexcept(false) {}   // COMPLIANT
  void *operator new[](size_t, void *) noexcept(false) {} // COMPLIANT
};

struct S4 {
  void operator delete(void *) noexcept(false) {}   // NON_COMPLIANT
  void operator delete[](void *) noexcept(false) {} // NON_COMPLIANT
};
