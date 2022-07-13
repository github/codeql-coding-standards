#include <cstddef>

void *operator new(size_t count) {} // NON_COMPLIANT

class A { // NON_COMPLIANT
  static void *operator new(size_t count) {}
};

class B { // COMPLIANT
  static void *operator new(size_t count) {}
  static void operator delete(void *ptr) {}
};

struct C { // NON_COMPLIANT
  static void *operator new(size_t count) {}
};

struct D { // COMPLIANT
  static void *operator new(size_t count) {}
  static void operator delete(void *ptr) {}
};