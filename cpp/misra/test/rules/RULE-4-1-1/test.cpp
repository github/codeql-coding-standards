#include <cstdarg>
#include <type_traits>

alignas(8) int g0;                   // COMPLIANT
[[maybe_unused]] int g1;             // COMPLIANT
[[noreturn]] void f1();              // COMPLIANT
[[maybe_unused]] void f2();          // COMPLIANT
[[deprecated]] void f3();            // COMPLIANT
[[nodiscard]] void f4();             // COMPLIANT
[[carries_dependency]] void f5();    // COMPLIANT
[[gnu::maybe_unused]] int g2;        // NON_COMPLIANT
__attribute__((aligned(8))) int g3;  // NON_COMPLIANT
__attribute__((unused)) int g4;      // NON_COMPLIANT
void __attribute__((noreturn)) f6(); // NON_COMPLIANT
[[gnu::deprecated]] void f7();       // NON_COMPLIANT
[[nonstandard_attribute]] void f8(); // NON_COMPLIANT

void f9() {
  __builtin_popcount(15);       // NON_COMPLIANT
  __builtin_expect(1, 1);       // NON_COMPLIANT
  __sync_fetch_and_add(&g1, 1); // NON_COMPLIANT

  __is_abstract(int);             // NON_COMPLIANT -- gnu extension
  __is_same(int, long);           // NON_COMPLIANT -- gnu extension
  std::is_abstract<int>::value;   // COMPLIANT
  std::is_abstract_v<int>;        // COMPLIANT
  std::is_same<int, long>::value; // COMPLIANT
  std::is_same_v<int, long>;      // COMPLIANT

  ({ // NON_COMPLIANT
    int y = 5;
    y;
  });
  true ?: 42; // NON_COMPLIANT

  __int128 l0 = 0; // NON_COMPLIANT

  __alignof__(int); // NON_COMPLIANT[False negative]
  alignof(int);     // COMPLIANT

  switch (1) {
  case 1:
    [[fallthrough]]; // COMPLIANT
  case 2:
    __attribute__((fallthrough)); // NON_COMPLIANT
  case 3:
    [[gnu::fallthrough]]; // NON_COMPLIANT
  default:
  }
}

void f10(int x, ...) {
  va_list args;                // COMPLIANT
  va_start(args, x);           // COMPLIANT
  __builtin_va_start(args, x); // NON_COMPLIANT
}

struct ZeroLengthArray {
  int m0;
  int m1[0]; // NON_COMPLIANT -- gnu extension
};

typedef int t1;                                  // COMPLIANT
typedef int t2 __attribute__((vector_size(16))); // NON_COMPLIANT

#ifdef __has_builtin // NON_COMPLIANT -- clang extension
#endif

#ifdef __cplusplus // COMPLIANT
#endif

#pragma once
#pragma GCC diagnostic push // NON_COMPLIANT
#warning "This is a warning" // NON_COMPLIANT
// clang-format off
#   warning "preceeding spaces is common" // NON_COMPLIANT
// clang-format on

const int g5 = 5;
void f12(int p0, int p1[10], int p2[], int p3[g5]) { // COMPLIANT -- not VLAs.
  int l0[p0];                                        // NON_COMPLIANT -- VLA
}