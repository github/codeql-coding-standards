#include <cstdint>
#include <string>

// Global variables for testing
std::uint32_t g1;
std::int32_t g2;
std::uint8_t g3;
std::int8_t g4;
std::uint16_t g5;
std::int16_t g6;
std::uint64_t g7;
std::int64_t g8;
float g9;
double g10;

// Test basic constant assignments
void test_constant_assignments() {
  g1 = 1;          // COMPLIANT
  g2 = 4u * 2u;    // COMPLIANT
  g3 = 3u;         // COMPLIANT
  g3 = 300u;       // NON_COMPLIANT
  g9 = 1;          // COMPLIANT
  g9 = 9999999999; // COMPLIANT
  g10 = 0.0f;      // NON_COMPLIANT
  g9 = 0.0f;       // COMPLIANT
}

// Test signedness violations
void test_signedness_violations() {
  g3 = g4; // NON_COMPLIANT
  g4 = g3; // NON_COMPLIANT
}

// Test size violations
void test_size_violations() {
  g3 = g5; // NON_COMPLIANT
  g5 = g7; // NON_COMPLIANT
}

// Test type category violations
void test_type_category_violations() {
  g9 = g2; // NON_COMPLIANT
  g2 = g9; // NON_COMPLIANT
}

// Test widening of id-expressions
void test_widening_id_expressions() {
  g1 = g3; // COMPLIANT
  g8 = g4; // COMPLIANT
  g7 = g5; // COMPLIANT
}

// Test expression results
void test_expression_results() {
  g3 = g3 + g3;              // NON_COMPLIANT
  std::int16_t l1 = g4 + g4; // NON_COMPLIANT
}

// Test bit-fields
struct S {
  std::uint32_t m1 : 2;
};

void test_bitfields() {
  S l1;
  l1.m1 = 2;   // COMPLIANT
  l1.m1 = 32u; // NON_COMPLIANT
  l1.m1 = g3;  // COMPLIANT
  l1.m1 = g5;  // NON_COMPLIANT
}

// Test enums
enum Colour : std::uint16_t { red, green, blue };

enum States { enabled, disabled };

void test_enums() {
  Colour l1 = red;
  g3 = red;     // COMPLIANT
  g1 = red;     // COMPLIANT
  g3 = l1;      // NON_COMPLIANT
  g1 = l1;      // COMPLIANT
  g3 = enabled; // COMPLIANT - enabled is not numeric
}

// Test function parameters - non-overload-independent
void f1(std::int64_t l1) {}
void f2(std::int32_t l1) {}

void test_function_parameters_non_overload_independent() {
  f1(g2); // NON_COMPLIANT
  f1(g8); // COMPLIANT
  f2(g2); // COMPLIANT
  f2(g8); // NON_COMPLIANT
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
  f3(g2); // COMPLIANT
  f3(g4); // NON_COMPLIANT
  f3(g8); // COMPLIANT
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
  f5("test", g3); // NON_COMPLIANT - will be promoted to `int`
  f5("test", g2); // COMPLIANT - already `int`, no promotion needed
}

// Test member function calls - not overload-independent
struct A {
  void f6(std::size_t l1, int l2) {}
  void f6(std::size_t l1, std::string l2) {}
  void f7();
};

void A::f7() {
  f6(g1, "answer");       // NON_COMPLIANT - extensible, could call a global
                          // function instead - e.g. `void f6(std::uint32_t l1,
                          // std::string l2)`
  this->f6(g1, "answer"); // COMPLIANT
  this->f6(g1, 42);       // COMPLIANT
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
  f9(MyInt{g4}); // COMPLIANT
  MyInt l1{g4};  // COMPLIANT
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
  switch (g4) {
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