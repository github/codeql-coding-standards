#include <cstdint>

struct S {
  int m1;
};

class C {
public:
  int m1;
};

void test_pointer_to_integral_casts() {
  S s;
  S *s_ptr = &s;
  C c;
  C *c_ptr = &c;
  int l1 = 42;
  int *int_ptr = &l1;
  void *void_ptr = &l1;

  // Non-compliant cases - pointer to integral type casts
  std::intptr_t l2 = reinterpret_cast<std::intptr_t>(s_ptr);   // NON_COMPLIANT
  std::uintptr_t l3 = reinterpret_cast<std::uintptr_t>(s_ptr); // NON_COMPLIANT
  std::int8_t l4 = reinterpret_cast<std::int8_t>(s_ptr);       // NON_COMPLIANT
  std::uint8_t l5 = reinterpret_cast<std::uint8_t>(s_ptr);     // NON_COMPLIANT
  std::int16_t l6 = reinterpret_cast<std::int16_t>(c_ptr);     // NON_COMPLIANT
  std::uint16_t l7 = reinterpret_cast<std::uint16_t>(c_ptr);   // NON_COMPLIANT
  std::int32_t l8 = reinterpret_cast<std::int32_t>(int_ptr);   // NON_COMPLIANT
  std::uint32_t l9 = reinterpret_cast<std::uint32_t>(int_ptr); // NON_COMPLIANT
  std::int64_t l10 = reinterpret_cast<std::int64_t>(void_ptr); // NON_COMPLIANT
  std::uint64_t l11 =
      reinterpret_cast<std::uint64_t>(void_ptr);              // NON_COMPLIANT
  long l12 = reinterpret_cast<long>(s_ptr);                   // NON_COMPLIANT
  unsigned long l13 = reinterpret_cast<unsigned long>(s_ptr); // NON_COMPLIANT
  int l14 = reinterpret_cast<int>(s_ptr);                     // NON_COMPLIANT
  unsigned int l15 = reinterpret_cast<unsigned int>(s_ptr);   // NON_COMPLIANT
}

void test_compliant_pointer_operations() {
  S s;
  S *s_ptr = &s;
  C c;
  C *c_ptr = &c;
  int l1 = 42;
  int *int_ptr = &l1;

  // Compliant cases - pointer to pointer casts
  void *l16 = static_cast<void *>(s_ptr);                // COMPLIANT
  S *l17 = static_cast<S *>(static_cast<void *>(s_ptr)); // COMPLIANT
  C *l18 = reinterpret_cast<C *>(s_ptr);                 // COMPLIANT

  // Compliant cases - using pointers without casting to integral
  S *l19 = s_ptr;         // COMPLIANT
  if (s_ptr != nullptr) { // COMPLIANT
    s_ptr->m1 = 10;       // COMPLIANT
  }
}

void test_function_pointer_to_integral() {
  void (*func_ptr)() = nullptr;

  // Non-compliant cases - function pointer to integral type casts
  std::intptr_t l20 =
      reinterpret_cast<std::intptr_t>(func_ptr); // NON_COMPLIANT
  std::uintptr_t l21 =
      reinterpret_cast<std::uintptr_t>(func_ptr); // NON_COMPLIANT
  long l22 = reinterpret_cast<long>(func_ptr);    // NON_COMPLIANT
}

void test_member_pointer_to_integral() {
  // Member pointer to integral type casts are forbidden by the rule, but also
  // prohibited by the compiler, e.g.
  //   int S::*member_ptr = &S::m1;
  //   std::intptr_t l23 = reinterpret_cast<std::intptr_t>(member_ptr);
  //   std::uintptr_t l24 = reinterpret_cast<std::uintptr_t>(member_ptr);
}