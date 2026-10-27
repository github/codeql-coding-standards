#include <cstdint>

struct A {
  explicit A(bool) {}
};
struct B {
  B(int) {}
};
struct BitField {
  std::uint8_t bit : 1;
};

void f1(std::int32_t n) {}
void f2(double d) {}

void test_bool_conversion_violations() {
  bool b1 = true;
  bool b2 = false;
  double d1 = 1.0;
  std::int8_t s8a = 0;
  std::int32_t s32a = 0;
  BitField bf;

  // Bitwise operations - non-compliant
  if (b1 & b2) { // NON_COMPLIANT
  }
  if (b1 | b2) { // NON_COMPLIANT
  }
  if (b1 ^ b2) { // NON_COMPLIANT
  }
  if (~b1) { // NON_COMPLIANT
  }

  // Relational operations - non-compliant
  if (b1 < b2) { // NON_COMPLIANT
  }
  if (b1 > b2) { // NON_COMPLIANT
  }
  if (b1 <= b2) { // NON_COMPLIANT
  }
  if (b1 >= b2) { // NON_COMPLIANT
  }

  // Comparison with integer literals - non-compliant
  if (b1 == 0) { // NON_COMPLIANT
  }
  if (b1 == 1) { // NON_COMPLIANT
  }
  if (b1 != 0) { // NON_COMPLIANT
  }

  // Arithmetic operations - non-compliant
  double l1 = d1 * b1;         // NON_COMPLIANT
  double l2 = d1 + b1;         // NON_COMPLIANT
  std::int32_t l3 = s32a + b1; // NON_COMPLIANT

  // Explicit casts to integral types - non-compliant
  s8a = static_cast<std::int8_t>(b1);   // NON_COMPLIANT
  s32a = static_cast<std::int32_t>(b1); // NON_COMPLIANT

  // Function parameter conversion - non-compliant
  f1(b1); // NON_COMPLIANT
  f2(b1); // NON_COMPLIANT

  // Switch statement - non-compliant
  switch (b1) { // NON_COMPLIANT
  case 0:
    break;
  case 1:
    break;
  }

  // Assignment to integral types - non-compliant
  s8a = b1;  // NON_COMPLIANT
  s32a = b1; // NON_COMPLIANT
  d1 = b1;   // NON_COMPLIANT
}

void test_bool_conversion_compliant() {
  bool b1 = true;
  bool b2 = false;
  std::int8_t s8a = 0;
  BitField bf;

  // Boolean equality operations - compliant
  if (b1 == false) { // COMPLIANT
  }
  if (b1 == true) { // COMPLIANT
  }
  if (b1 == b2) { // COMPLIANT
  }
  if (b1 != b2) { // COMPLIANT
  }

  // Logical operations - compliant
  if (b1 && b2) { // COMPLIANT
  }
  if (b1 || b2) { // COMPLIANT
  }
  if (!b1) { // COMPLIANT
  }

  // Conditional operator without conversion - compliant
  s8a = b1 ? 3 : 7; // COMPLIANT

  // Function parameter without conversion - compliant
  f1(b1 ? 1 : 0); // COMPLIANT

  // Explicit constructor calls - compliant
  A l1{true};                          // COMPLIANT
  A l2(false);                         // COMPLIANT
  A l3 = static_cast<A>(true);         // COMPLIANT
  A *l4 = reinterpret_cast<A *>(true); // NON_COMPLIANT - converted to integer
                                       //                 then pointer, does not
                                       //                 use constructor.
  B l5{true};                          // NON_COMPLIANT
  B l6(false);                         // NON_COMPLIANT
  B l7 = static_cast<B>(true);         // NON_COMPLIANT

  // Assignment to constructor - compliant
  A l8 = A{false}; // COMPLIANT

  // Bit-field assignment exception - compliant
  bf.bit = b1; // COMPLIANT
}

void f3(bool &b) {}
void f4(const bool &b) {}

template <typename T> void f5(T &&t) {}

template <typename T1, typename T2> struct Pair {
  template <typename U1, typename U2> Pair(U1 &&x, U2 &&y) : a(x), b(y) {}
  T1 a;
  T2 b;
};

void test_bool_reference_conversion_compliant() {
  bool b1 = true;

  // Binding a bool lvalue to a bool reference parameter - compliant, no
  // actual type conversion takes place.
  f3(b1); // COMPLIANT

  // Binding a bool value to a const bool reference parameter - compliant.
  f4(b1);   // COMPLIANT
  f4(true); // COMPLIANT

  // Binding a bool value to a forwarding reference parameter deduced as
  // bool - compliant.
  f5(b1);   // COMPLIANT
  f5(true); // COMPLIANT

  // Binding a bool value through a generic forwarding-reference constructor,
  // where the second template parameter is deduced as bool - compliant. This
  // mirrors idiomatic `return {value, overflow_flag};` and structured-binding
  // patterns (e.g. std::pair and std::map::insert()'s return value).
  Pair<int, bool> p1{1, true};  // COMPLIANT
  Pair<int, bool> p2 = {1, b1}; // COMPLIANT
}