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

// Test basic constant assignments
void test_constant_assignments() {
  u32 = 1;          // COMPLIANT
  s32 = 4u * 2u;    // COMPLIANT
  u8 = 3u;         // COMPLIANT
  u8 = 300u;       // NON_COMPLIANT
  f = 1;          // COMPLIANT
  f = 9999999999; // COMPLIANT
  d = 0.0f;      // NON_COMPLIANT
  f = 0.0f;       // COMPLIANT
}

// Test signedness violations
void test_signedness_violations() {
  u8 = s8; // NON_COMPLIANT
  s8 = u8; // NON_COMPLIANT
}

// Test size violations
void test_size_violations() {
  u8 = u16; // NON_COMPLIANT
  u16 = u64; // NON_COMPLIANT
}

// Test type category violations
void test_type_category_violations() {
  f = s32; // NON_COMPLIANT
  s32 = f; // NON_COMPLIANT
}

// Test widening of id-expressions
void test_widening_id_expressions() {
  u32 = u8; // COMPLIANT
  s64 = s8; // COMPLIANT
  u64 = u16; // COMPLIANT
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
  l1.m1 = u16;  // NON_COMPLIANT
}

// Test enums
enum Colour : std::uint16_t { red, green, blue };

enum States { enabled, disabled };

void test_enums() {
  Colour l1 = red;
  u8 = red;     // COMPLIANT
  u32 = red;     // COMPLIANT
  u8 = l1;      // NON_COMPLIANT
  u32 = l1;      // COMPLIANT
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
  f3(s8); // NON_COMPLIANT
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
  f5("test", u8); // NON_COMPLIANT - will be promoted to `int`
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