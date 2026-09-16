#include <cstdint>
#include <iostream>

// Global variables for testing
std::uint8_t g1 = 5;
std::uint8_t g2 = 10;
std::uint8_t g3 = 15;
std::uint8_t g4 = 20;
std::int16_t g5 = 100;
std::int32_t g6 = 200;
bool g7 = true;
std::int32_t g8[5] = {1, 2, 3, 4, 5};

// Function declarations
std::int32_t f1();
bool f2();
std::int32_t *f3();

// Class with explicit operator bool
class TestClassExplicit {
  std::int32_t m1;

public:
  explicit operator bool() const { return m1 < 0; }
};

class TestClassImplicit {
  std::int32_t m1;

public:
  operator bool() const { return m1 < 0; } // Implicit conversion
};

// Class with member function pointer
class TestClassMemberFunc {
public:
  void memberFunc() {}
};

// Bit-field struct for exception #3
struct BitFieldStruct {
  unsigned int m1 : 1;
};

void test_logical_operators() {
  std::uint8_t l1 = 5;
  std::uint8_t l2 = 10;
  std::uint8_t l3 = 15;
  std::uint8_t l4 = 20;

  if ((l1 < l2) && (l3 < l4)) { // COMPLIANT
  }
  if ((l1 < l2) && (l3 + l4)) { // NON_COMPLIANT
  }
  if (true && (l3 < l4)) { // COMPLIANT
  }
  if (1 && (l3 < l4)) { // NON_COMPLIANT
  }
  if (l1 && (l3 < l4)) { // NON_COMPLIANT
  }
  if (!0) { // NON_COMPLIANT
  }
  if (!false) { // COMPLIANT
  }
  if (l1) { // NON_COMPLIANT
  }
}

void test_conditional_operator() {
  std::int32_t l1 = 100;
  std::int32_t l2 = 200;
  std::int32_t l3 = 300;
  std::int16_t l4 = 50;
  bool l5 = true;

  l1 = l4 ? l2 : l3;       // NON_COMPLIANT
  l1 = l5 ? l2 : l3;       // COMPLIANT
  l1 = (l4 < 5) ? l2 : l3; // COMPLIANT
}

void test_if_statements() {
  std::int32_t l1;
  bool l2 = f2();

  if (std::int32_t l3 = f1()) { // NON_COMPLIANT
  }
  if (std::int32_t l4 = f1(); l4 != 0) { // COMPLIANT
  }
  if (bool l5 = f2()) { // COMPLIANT
  }
  if (std::int32_t l6 = f1(); l6) { // NON_COMPLIANT
  }
}

void test_while_loops() {
  while (std::int32_t l1 = f1()) { // COMPLIANT - exception #4
  }

  for (std::int32_t l2 = 10; l2; --l2) { // NON_COMPLIANT
  }

  while (std::cin) { // COMPLIANT - exception #2
  }
}

void test_do_while_loops() {
  std::int32_t l1 = 5;
  bool l2 = true;

  do {
    --l1;
  } while (l1); // NON_COMPLIANT

  do {
    --l1;
  } while (l2); // COMPLIANT

  do {
    --l1;
  } while (l1 > 0); // COMPLIANT
}

void test_pointer_conversions() {
  if (f3()) { // COMPLIANT - exception #2
  }

  bool l1 = f3();            // NON_COMPLIANT
  bool l2 = f3() != nullptr; // COMPLIANT

  if (nullptr) { // COMPLIANT
  }
}

void test_assignment_to_bool() {
  bool l1 = static_cast<bool>(4); // NON_COMPLIANT
  bool l2 = g1;                   // NON_COMPLIANT
  bool l3 = (g1 < g2);            // COMPLIANT
  bool l4 = g7;                   // COMPLIANT
  bool l5 = bool(4);              // NON_COMPLIANT
  bool l6 = (bool)4;              // NON_COMPLIANT
}

void test_classes_with_bool_operators() {
  TestClassExplicit l1;

  bool l2 = static_cast<bool>(l1); // COMPLIANT - exception #1
  if (l1) {                        // COMPLIANT - exception #2
  }
  TestClassImplicit l3;
  bool l4 = l3; // NON_COMPLIANT
}

void test_bitfield_conversion() {
  BitFieldStruct l1;

  bool l2 = l1.m1; // COMPLIANT - exception #3
}

void test_unscoped_enum_conversion() {
  enum Color { RED, GREEN, BLUE };
  Color l1 = RED;

  bool l2 = l1; // NON_COMPLIANT
  if (l1) {     // NON_COMPLIANT
  }
  bool l3 = (l1 == RED); // COMPLIANT
}

void test_scoped_enum_conversion() {
  enum class Status { ACTIVE, INACTIVE };
  Status l1 = Status::ACTIVE;

  bool l2 = (l1 == Status::ACTIVE); // COMPLIANT
}

void test_floating_point_conversion() {
  float l1 = 3.14f;
  double l2 = 2.71;
  long double l3 = 1.41L;

  bool l4 = l1; // NON_COMPLIANT
  bool l5 = l2; // NON_COMPLIANT
  bool l6 = l3; // NON_COMPLIANT
  if (l1) {     // NON_COMPLIANT
  }
  if (l2) { // NON_COMPLIANT
  }
  if (l3) { // NON_COMPLIANT
  }
  bool l7 = (l1 > 0.0f); // COMPLIANT
  bool l8 = (l2 != 0.0); // COMPLIANT
}

void test_array_conversion() {
  std::int32_t l1[5] = {1, 2, 3, 4, 5};

  if (l1) { // COMPLIANT
  }
  if (g8) { // COMPLIANT
  }
  bool l2 = l1;              // NON_COMPLIANT
  bool l3 = (l1 != nullptr); // COMPLIANT
}

void test_member_function_pointer_conversion() {
  void (TestClassMemberFunc::*l1)() = &TestClassMemberFunc::memberFunc;
  void (TestClassMemberFunc::*l2)() = nullptr;

  if (l1) { // COMPLIANT - exception #2
  }
  if (l2) { // COMPLIANT - exception #2
  }
  bool l3 = l1;              // NON_COMPLIANT
  bool l4 = l2;              // NON_COMPLIANT
  bool l5 = (l1 != nullptr); // COMPLIANT
}

// Regression test for a false positive where the compiler-synthesized
// `get<N>(...)` call used to implement structured binding decomposition (`auto
// [a, b] = ...;`) was incorrectly flagged as a "conversion to bool", even
// though the decomposed member is already `bool` - dereferencing a
// `bool&`/`bool&&` reference is not a conversion from another type to `bool`.
struct BoolPair {
  std::int32_t first;
  bool second;
};

template <std::size_t I> auto get(const BoolPair &p) {
  if constexpr (I == 0) {
    return p.first;
  } else {
    return p.second;
  }
}

namespace std {
template <class T> struct tuple_size;
template <std::size_t I, class T> struct tuple_element;

template <> struct tuple_size<BoolPair> {
  static constexpr std::size_t value = 2;
};
template <> struct tuple_element<0, BoolPair> { using type = std::int32_t; };
template <> struct tuple_element<1, BoolPair> { using type = bool; };
} // namespace std

BoolPair make_bool_pair();

void test_structured_binding_bool_decomposition() {
  auto [l1, l2] =
      make_bool_pair(); // COMPLIANT - structured binding decomposition, not a
                        // real conversion to bool
  if (l2) {             // COMPLIANT
  }
  bool l3 = l2; // COMPLIANT - l2 is already bool
}

// Regression test for a false positive where a `constexpr bool` variable
// template, whose initializer is itself a dependent expression built from
// another variable template, was incorrectly flagged as a "conversion from
// 'unknown' to bool". The extractor cannot resolve a concrete type for a
// dependent, uninstantiated template expression, so it should not be treated as
// an actual conversion.
template <typename T> constexpr bool is_something_v = true;

template <typename T>
constexpr bool derived_from_template_v = is_something_v<T>; // COMPLIANT

bool test_dependent_variable_template_instantiation() {
  return derived_from_template_v<std::int32_t>; // COMPLIANT
}