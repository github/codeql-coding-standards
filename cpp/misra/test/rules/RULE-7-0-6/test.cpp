#include <cstdint>
#include <string>

// Global variables for testing
std::uint32_t u32;
std::int32_t s32;
std::uint8_t u8;
std::int8_t s8;
std::uint16_t u16;
std::int16_t s16;
std::uint64_t u64;
std::int64_t s64;
float f;
double d;

namespace TestNamespace {
std::uint8_t g1;
std::uint16_t g2;
} // namespace TestNamespace

struct TestStruct {
  std::uint8_t m1;
  std::uint16_t m2;
  static std::uint8_t s1;
  static std::uint16_t s2;
};

std::uint8_t TestStruct::s1;
std::uint16_t TestStruct::s2;

// Test basic constant assignments
void test_constant_assignments() {
  u32 = 1;        // COMPLIANT
  s32 = 4u * 2u;  // COMPLIANT
  u8 = 3u;        // COMPLIANT
  u8 = 300u;      // NON_COMPLIANT
  f = 1;          // COMPLIANT
  f = 9999999999; // COMPLIANT
  d = 0.0f;       // NON_COMPLIANT
  f = 0.0f;       // COMPLIANT
}

// Test signedness violations
void test_signedness_violations() {
  u8 = s8; // NON_COMPLIANT
  s8 = u8; // NON_COMPLIANT
}

// Test size violations
void test_size_violations() {
  u8 = u16;  // NON_COMPLIANT
  u16 = u64; // NON_COMPLIANT
}

// Test type category violations
void test_type_category_violations() {
  f = s32; // NON_COMPLIANT
  s32 = f; // NON_COMPLIANT
}

// Test widening of id-expressions
void test_widening_id_expressions() {
  u32 = u8;  // COMPLIANT - widening of id-expression
  s64 = s8;  // COMPLIANT - widening of id-expression
  u64 = u16; // COMPLIANT - widening of id-expression
}

// Test widening with namespace qualifiers (allowed)
void test_widening_namespace_qualified() {
  u32 = TestNamespace::g1; // COMPLIANT - namespace qualified id-expression
  u64 = TestNamespace::g2; // COMPLIANT - namespace qualified id-expression
}

// Test widening with type qualifiers (allowed)
void test_widening_type_qualified() {
  u32 = TestStruct::s1; // COMPLIANT - type qualified id-expression
  u64 = TestStruct::s2; // COMPLIANT - type qualified id-expression
}

// Test widening with decltype (allowed)
void test_widening_decltype_qualified() {
  std::uint8_t l1 = 42;
  std::uint16_t l2 = 42;
  u32 = decltype(l1){}; // COMPLIANT - treated as a constant
  u64 = decltype(l2){}; // COMPLIANT - treated as a constant
  TestStruct l3;
  u32 = decltype(l3)::s1; // COMPLIANT - decltype qualified
  u64 = decltype(l3)::s2; // COMPLIANT - decltype qualified
}

// Test widening with object member access (not allowed)
void test_widening_object_member_access() {
  TestStruct l1;
  TestStruct *l2 = &l1;
  u32 = l1.m1;  // NON_COMPLIANT - object member access, not id-expression
  u64 = l1.m2;  // NON_COMPLIANT - object member access, not id-expression
  u32 = l2->m1; // NON_COMPLIANT - object member access, not id-expression
  u64 = l2->m2; // NON_COMPLIANT - object member access, not id-expression
}

// Test widening with expressions (not allowed)
void test_widening_expressions() {
  u32 = u8 + 0; // NON_COMPLIANT - not id-expression
  u32 = (u8);   // NON_COMPLIANT - not id-expression (parenthesized)
  u32 = static_cast<std::uint8_t>(u8); // NON_COMPLIANT - not id-expression
}

// Test expression results
void test_expression_results() {
  u8 = u8 + u8;              // NON_COMPLIANT
  std::int16_t l1 = s8 + s8; // NON_COMPLIANT
}

// Test bit-fields
struct S {
  std::uint32_t m1 : 2;
};

void test_bitfields() {
  S l1;
  l1.m1 = 2;   // COMPLIANT
  l1.m1 = 32u; // NON_COMPLIANT
  l1.m1 = u8;  // COMPLIANT
  l1.m1 = u16; // NON_COMPLIANT
}

// Test enums
enum Colour : std::uint16_t { red, green, blue };

enum States { enabled, disabled };

void test_enums() {
  Colour l1 = red;
  u8 = red;     // COMPLIANT
  u32 = red;    // COMPLIANT
  u8 = l1;      // NON_COMPLIANT
  u32 = l1;     // COMPLIANT
  u8 = enabled; // COMPLIANT - enabled is not numeric
}

// Test function parameters - non-overload-independent
void f1(std::int64_t l1) {}
void f2(std::int32_t l1) {}

void test_function_parameters_non_overload_independent() {
  f1(s32); // NON_COMPLIANT
  f1(s64); // COMPLIANT
  f2(s32); // COMPLIANT
  f2(s64); // NON_COMPLIANT
  int l1 = 42;
  f2(l1); // NON_COMPLIANT - needs to be the same type as the parameter
  signed int l2 = 42;
  f2(l2); // COMPLIANT - int32_t is defined as `signed int` in this database
}

// Test overloaded functions, but still non-overload-independent
// because they are "extensible" (i.e., they can be extended with new
// overloads).
void f3(std::int64_t l1) {}
void f3(std::int32_t l1) {}

void test_overloaded_functions() {
  f3(s32); // COMPLIANT
  f3(s8);  // NON_COMPLIANT
  f3(s64); // COMPLIANT
}

// Test function pointers - always "overload-independent"
void f4(long l1) {}

void test_function_pointers() {
  void (*l1)(long) = &f4;
  f4(2); // NON_COMPLIANT
  l1(2); // COMPLIANT
}

// Test variadic functions
void f5(const char *l1, ...) {}

void test_variadic_functions() {
  f5("test", u8);  // NON_COMPLIANT - will be promoted to `int`
  f5("test", s32); // COMPLIANT - already `int`, no promotion needed
}

// Test member function calls - not overload-independent
struct A {
  void f6(std::size_t l1, int l2) {}
  void f6(std::size_t l1, std::string l2) {}
  void f7();
};

void A::f7() {
  f6(u32, "answer");       // NON_COMPLIANT - extensible, could call a global
                           // function instead - e.g. `void f6(std::uint32_t l1,
                           // std::string l2)`
  this->f6(u32, "answer"); // COMPLIANT
  this->f6(u32, 42);       // COMPLIANT
}

void test_member_function_overload_independent() {
  A l1;
  l1.f6(42, "answer"); // COMPLIANT
  A *l2 = &l1;
  l2->f6(42, "answer"); // COMPLIANT
}

// Test member function calls - not overload-independent
struct B {
  void f8(int l1, int l2) {}
  void f8(long l1, std::string l2) {}
};

void test_member_function_not_overload_independent() {
  B l1;
  l1.f8(42, "answer"); // NON_COMPLIANT
}

// Test constructor exception
struct MyInt {
  explicit MyInt(std::int32_t l1) {}
  MyInt(std::int32_t l1, std::int32_t l2) {}
};

void f9(MyInt l1) {}

void test_constructor_exception() {
  f9(MyInt{s8}); // COMPLIANT
  MyInt l1{s8};  // COMPLIANT
}

// Test template functions - not overload-independent
template <typename T> struct D {
  void f10(T l1, int l2) {}
  void f10(T l1, std::string l2) {}
  template <typename S1> void f11(S1 l1, int l2) {}
  template <typename S2> void f11(S2 l1, std::string l2) {}
  void f11(std::int32_t l1, float f) {}
};

void test_template_functions() {
  D<std::size_t> l1;
  l1.f10(42, "X");              // COMPLIANT
  l1.f10(42, 1);                // COMPLIANT
  l1.f11<std::size_t>(42, "X"); // NON_COMPLIANT - int not size_t
  l1.f11<int>(42, 1);           // COMPLIANT - same as specialized type
  l1.f11(42, 0.0f);             // COMPLIANT - same as specialized type
}

// Test initialization forms
std::int32_t f12(std::int8_t l1) {
  std::int16_t l2 = l1;     // COMPLIANT
  std::int16_t l3{l1};      // COMPLIANT
  std::int16_t l4(l1);      // COMPLIANT
  std::int16_t l5{l1 + l1}; // NON_COMPLIANT
  return l1;                // COMPLIANT
}

std::int32_t test_return() {
  return u32; // NON_COMPLIANT - wrong signedness
}

// Test switch cases
void test_switch_cases() {
  switch (s8) {
  case 1: // COMPLIANT
    break;
  case 0x7F: // COMPLIANT
    break;
  case 0x80: // COMPLIANT - condition subject to promotion
    break;
    // Our extractor and supported compilers prohibit the below
    // narrowing conversion.
    //    case 0xFFFF'FFFF'FFFF:
    //      break;
  }
}

// Test reference types - references to numeric types are considered numeric
void test_reference_types_basic() {
  std::uint8_t l1 = 42;
  std::uint32_t l2 = 100;
  std::int8_t l3 = -5;
  float l4 = 3.14f;

  std::uint8_t &l5 = l1;  // COMPLIANT
  std::uint32_t &l6 = l2; // COMPLIANT
  std::int8_t &l7 = l3;   // COMPLIANT
  float &l8 = l4;         // COMPLIANT

  // Reference types follow same rules as their referred types
  u32 = l5; // COMPLIANT - widening of id-expression (reference)
  u8 = l6;  // NON_COMPLIANT - narrowing from reference
  u8 = l7;  // NON_COMPLIANT - different signedness from reference
  s32 = l8; // NON_COMPLIANT - different type category from reference
}

void test_reference_types_function_parameters() {
  std::uint8_t l1 = 42;
  std::uint16_t l2 = 1000;

  std::uint8_t &l3 = l1;
  std::uint16_t &l4 = l2;

  // Function calls with reference arguments
  f1(l3); // NON_COMPLIANT - widening conversion through reference
  f2(l4); // NON_COMPLIANT - narrowing conversion through reference
}

void test_reference_types_signedness() {
  std::uint8_t l1 = 42;
  std::int8_t l2 = -5;

  std::uint8_t &l3 = l1;
  std::int8_t &l4 = l2;

  // Signedness violations through references
  s8 = l3; // NON_COMPLIANT - different signedness through reference
  u8 = l4; // NON_COMPLIANT - different signedness through reference
}

void test_reference_types_floating_point() {
  float l1 = 3.14f;
  double l2 = 2.718;
  std::int32_t l3 = 42;

  float &l4 = l1;
  double &l5 = l2;
  std::int32_t &l6 = l3;

  // Type category violations through references
  s32 = l4; // NON_COMPLIANT - different type category through reference
  f = l5;   // NON_COMPLIANT - different size through reference
  f = l6;   // NON_COMPLIANT - different type category through reference
}

void test_reference_types_expressions() {
  std::uint8_t l1 = 42;
  std::uint8_t l2 = 24;

  std::uint8_t &l3 = l1;
  std::uint8_t &l4 = l2;

  // Expression results with references still follow expression rules
  u8 = l3 + l4;  // NON_COMPLIANT - addition promotes to int
  s32 = l3 + l4; // COMPLIANT - promotion to int
}

// Test reference parameters in functions
void f13(std::uint8_t &l1) {}
void f13(std::uint16_t &l1) {}

void f14(std::uint32_t l1) {}

void test_references_to_parameters() {
  std::uint8_t l1 = 42;
  std::uint16_t l2 = 1000;

  f13(l1); // COMPLIANT - not covered by rule, as pass-by-ref
  f13(l2); // COMPLIANT - not covered by rule, as pass-by-ref

  std::uint16_t &l3 = l2;
  f14(l3); // NON_COMPLIANT - must be the same type, as non-overload-independent
  std::uint64_t l4 = 1000;
  std::uint64_t &l5 = l4;
  f14(l5); // NON_COMPLIANT - narrowing conversion through reference
}

// Test compound assignments - rule does not apply to compound assignments
void test_compound_assignments() {
  std::uint8_t l1 = 10;
  std::uint16_t l2 = 100;
  std::int8_t l3 = 5;
  float l4 = 1.5f;

  l1 += l2;  // COMPLIANT - compound assignment, rule does not apply
  l1 -= l3;  // COMPLIANT - compound assignment, rule does not apply
  l2 *= l1;  // COMPLIANT - compound assignment, rule does not apply
  l2 /= l3;  // COMPLIANT - compound assignment, rule does not apply
  l1 %= l3;  // COMPLIANT - compound assignment, rule does not apply
  l2 &= l1;  // COMPLIANT - compound assignment, rule does not apply
  l2 |= l3;  // COMPLIANT - compound assignment, rule does not apply
  l2 ^= l1;  // COMPLIANT - compound assignment, rule does not apply
  l2 <<= 2;  // COMPLIANT - compound assignment, rule does not apply
  l2 >>= 1;  // COMPLIANT - compound assignment, rule does not apply
  l4 += l1;  // COMPLIANT - compound assignment, rule does not apply
  l4 -= s32; // COMPLIANT - compound assignment, rule does not apply
}