#include <cstdint>
#include <cstring>
#include <string.h>

void test_memcpy_usage() {
  std::uint8_t l1[10];
  std::uint8_t l2[10];

  memcpy(l1, l2, 10);      // NON_COMPLIANT
  std::memcpy(l1, l2, 10); // NON_COMPLIANT
}

void test_memmove_usage() {
  std::uint8_t l1[10];
  std::uint8_t l2[10];

  memmove(l1, l2, 10);      // NON_COMPLIANT
  std::memmove(l1, l2, 10); // NON_COMPLIANT
}

void test_memcmp_usage() {
  std::uint8_t l1[10];
  std::uint8_t l2[10];

  int l3 = memcmp(l1, l2, 10);      // NON_COMPLIANT
  int l4 = std::memcmp(l1, l2, 10); // NON_COMPLIANT
}

void test_function_pointers() {
  void *(*l1)(void *, const void *, std::size_t) = memcpy;     // NON_COMPLIANT
  void *(*l2)(void *, const void *, std::size_t) = memmove;    // NON_COMPLIANT
  int (*l3)(const void *, const void *, std::size_t) = memcmp; // NON_COMPLIANT

  void *(*l4)(void *, const void *, std::size_t) = std::memcpy; // NON_COMPLIANT
  void *(*l5)(void *, const void *, std::size_t) =
      std::memmove; // NON_COMPLIANT
  int (*l6)(const void *, const void *, std::size_t) =
      std::memcmp; // NON_COMPLIANT
}

struct S {
  bool m1;
  std::int64_t m2;
};

void test_struct_comparison() {
  S l1{true, 42};
  S l2{true, 42};

  if (memcmp(&l1, &l2, sizeof(S)) != 0) { // NON_COMPLIANT
  }

  if (std::memcmp(&l1, &l2, sizeof(S)) != 0) { // NON_COMPLIANT
  }
}

void test_buffer_comparison() {
  char l1[12];
  char l2[12];

  if (memcmp(l1, l2, sizeof(l1)) != 0) { // NON_COMPLIANT
  }

  if (std::memcmp(l1, l2, sizeof(l1)) != 0) { // NON_COMPLIANT
  }
}

void test_overlapping_memory() {
  std::uint8_t l1[20];

  memcpy(l1 + 5, l1, 10);  // NON_COMPLIANT
  memmove(l1 + 5, l1, 10); // NON_COMPLIANT

  std::memcpy(l1 + 5, l1, 10);  // NON_COMPLIANT
  std::memmove(l1 + 5, l1, 10); // NON_COMPLIANT
}

#define CUSTOM_MEMCPY memcpy   // NON_COMPLIANT
#define CUSTOM_MEMMOVE memmove // NON_COMPLIANT
#define CUSTOM_MEMCMP memcmp   // NON_COMPLIANT

void test_macro_expansion() {
  std::uint8_t l1[10];
  std::uint8_t l2[10];

  CUSTOM_MEMCPY(l1, l2, 10);
  CUSTOM_MEMMOVE(l1, l2, 10);
  int l3 = CUSTOM_MEMCMP(l1, l2, 10);
}