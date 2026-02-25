#include <cstdint>

// Test case 1: Type aliases in block scope
std::int16_t test_type_alias_unused() {
  using T1 = std::int16_t; // NON_COMPLIANT - T1 declared but not used
  return 67;
}

std::int16_t test_type_alias_used() {
  using T1 = std::int16_t; // COMPLIANT - T1 is used below
  T1 l1 = 42;
  return l1;
}

std::int16_t test_type_alias_maybe_unused() {
  using T1 [[maybe_unused]] = std::int32_t; // COMPLIANT - Exception #1
  return 67;
}

// Test case 2: Types in unnamed namespace
namespace {
struct A1 {
  A1 f();
}; // COMPLIANT[False Positive] - A1 is used in uninstantiated template

void f1() {
  A1 l1; // Use of A1
  l1.f();
}

struct A2 {
  A2 f();
}; // NON_COMPLIANT - A2 is not used (only in its own definition)

struct A2; // Not a use of A2

A2 A2::f() { return *this; } // Not a use of A2
} // namespace

// Test case 3: Struct in constexpr if
template <bool cond> inline auto test_constexpr_if() {
  struct res {
    std::int32_t i;
  }; // COMPLIANT - res is used in else branch
  if constexpr (cond) {
    return 42;
  } else {
    return res{42}; // res is utilized
  }
}

// Test case 4: Type used as template argument
template <typename> std::int32_t bar() { return 42; }

std::int32_t test_template_argument() {
  return bar<struct P>(); // COMPLIANT - P is used
}

// Test case 5: Class template specialization
namespace {
template <typename> struct C1 {}; // NON_COMPLIANT - only used in its definition

template <> struct C1<std::int32_t> { // COMPLIANT - Exception #3
  void mbr() { C1<char> l1; }
};
} // namespace

namespace {
template <typename> struct C2 {}; // COMPLIANT - C2<float> is used below

template <> struct C2<std::int32_t>; // COMPLIANT - Exception #3

C2<float> g1; // Use of C2
} // namespace

// Test case 6: Anonymous unions
namespace {
static union {
  std::int32_t i1;
  std::int32_t j1;
}; // NON_COMPLIANT - anonymous union not used

static union {
  std::int32_t i2;
  std::int32_t j2;
}; // COMPLIANT - i2 is used in f3
} // namespace

void test_anonymous_union() {
  ++i2; // Uses the anonymous union holding i2
}

// Test case 7: Lambda closure type
namespace {
void test_lambda_closure() {
  [](auto) {}; // COMPLIANT - closure type is always used
}
} // namespace

// Test case 8: Enumeration type usage
namespace {
enum class E1 { A, B, C }; // COMPLIANT - E1 is used via its enumerators

enum class E2 { D, E, F }; // NON_COMPLIANT - E2 is not used
} // namespace

void test_enum_usage() {
  auto l1 = E1::A; // Use of E1
}

// Test case 9: Multiple type aliases
void test_multiple_aliases() {
  using T1 = std::int32_t; // COMPLIANT - T1 is used
  using T2 = std::int64_t; // NON_COMPLIANT - T2 is not used
  T1 l1 = 0;
}

// Test case 10: Nested struct in block scope
void test_nested_struct() {
  struct S1 {
    std::int32_t m1;
  }; // COMPLIANT - S1 is used below
  S1 l1{42};

  struct S2 {
    std::int32_t m2;
  }; // NON_COMPLIANT - S2 is not used
}

// Test case 11: Class with hidden friend
namespace {
struct A3 {
  friend void hidden_friend(A3) {} // Part of A3's definition
}; // NON_COMPLIANT - A3 is not used outside its definition

// non-hidden friend
struct A4 { // COMPLIANT - A4 is used outside its definition
  friend void non_hidden_friend(A4 a);
};

void non_hidden_friend(A4 a) {}

struct A5 {}; // COMPLIANT -- used in A6 hidden friend
struct A6 {   // NON_COMPLIANT -- not used in hidden friend
  friend void wrong_hidden_friend(A5) {}
};
} // namespace

// Test case 12: Alias templates
namespace {
template <typename T> using AliasTemplate1 = T *; // NON_COMPLIANT

template <typename T> using AliasTemplate2 = T *; // COMPLIANT

void test_alias_template() { AliasTemplate2<int> l1; }
} // namespace

// Test case 13: Primary class template usage
namespace {
template <typename T> struct D1 {
  T m1;
}; // COMPLIANT - D1<int> is used

void test_class_template_usage() { D1<int> l1{42}; }
} // namespace

// Test case 14: Type in return type
namespace {
struct R1 {
  std::int32_t m1;
}; // COMPLIANT - R1 is used in return type

R1 test_return_type() { return R1{42}; }
} // namespace

// Test case 15: Type in parameter
namespace {
struct P1 {
  std::int32_t m1;
}; // COMPLIANT - P1 is used in parameter

void test_parameter_type(P1 l1) {}
} // namespace

// Test case 16: Forward declaration followed by use
namespace {
struct F1; // Not a use

struct F1 {
  std::int32_t m1;
}; // COMPLIANT - F1 is used below

void test_forward_declaration() { F1 l1{0}; }
} // namespace