#include <stddef.h>

struct StructA {
  char elems[32];
};

struct alignas(32) StructAOverAligned {
  char elems[32];
};

void test_over_aligned() {
  StructA *a1 = new StructA{};                       // COMPLIANT
  StructAOverAligned *a2 = new StructAOverAligned{}; // NON_COMPLIANT
}