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

// Test bit-fields with various sizes around boundaries
struct S {
  std::uint32_t m1 : 2;  // 2-bit field
  std::uint32_t m2 : 8;  // 8-bit field (boundary)
  std::uint32_t m3 : 9;  // 9-bit field (boundary + 1)
  std::uint32_t m4 : 16; // 16-bit field (boundary)
  std::uint32_t m5 : 17; // 17-bit field (boundary + 1)
  std::uint32_t m6 : 32; // 32-bit field (boundary)
  std::uint64_t m7 : 33; // 33-bit field (boundary + 1)
  std::int32_t m8 : 5;   // Signed 5-bit field
  std::int32_t m9 : 12;  // Signed 12-bit field
  std::int32_t m10 : 28; // Signed 28-bit field
};

void test_bitfields() {
  S l1;

  // 2-bit field tests
  l1.m1 = 2; // COMPLIANT - value fits in 2 bits
  l1.m1 = 3; // COMPLIANT - value fits in 2 bits
  l1.m1 = 4; // NON_COMPLIANT - constant does not fit in 2 bits

  l1.m1 = u8;  // COMPLIANT - u8 is fine, not integer constant
  l1.m1 = u16; // NON_COMPLIANT - narrowing from uint16_t

  // 8-bit boundary field tests
  l1.m2 = 255; // COMPLIANT - value fits in uint8_t
  l1.m2 = 256; // NON_COMPLIANT - value does not fit in unint8_t
  l1.m2 = u8;  // COMPLIANT - same width as uint8_t
  l1.m2 = u16; // NON_COMPLIANT - narrowing from uint16_t
  l1.m2 = u32; // NON_COMPLIANT - narrowing from uint32_t

  // 9-bit boundary + 1 field tests
  l1.m3 = 511;   // COMPLIANT
  l1.m3 = 512;   // NON_COMPLIANT - value does not fit in 9 bits
  l1.m3 = 65535; // NON_COMPLIANT - value does not fit in 9 bits
  l1.m3 = 65536; // NON_COMPLIANT - value does not fit in 9 bits
  l1.m3 = u8;    // COMPLIANT - widening from uint8_t to uint16_t
  l1.m3 = u16;   // COMPLIANT
  l1.m3 = u32;   // NON_COMPLIANT - narrowing from uint32_t

  // 16-bit boundary field tests
  l1.m4 = 65535; // COMPLIANT - value fits in 16 bits
  l1.m4 = 65536; // NON_COMPLIANT - value does not fit in 16 bits
  l1.m4 = u8;    // COMPLIANT - widening from uint8_t
  l1.m4 = u16;   // COMPLIANT - same width as uint16_t
  l1.m4 = u32;   // NON_COMPLIANT - narrowing from uint32_t

  // 17-bit boundary + 1 field tests
  l1.m5 = 131071; // COMPLIANT - value fits in 17 bits
  l1.m5 = 131072; // NON_COMPLIANT - value does not fit in 17 bits
  l1.m5 = u8;     // COMPLIANT - widening from uint8_t
  l1.m5 = u16;    // COMPLIANT - widening from uint16_t
  l1.m5 = u32;    // COMPLIANT
  l1.m5 = u64;    // NON_COMPLIANT - narrowing from uint64_t

  // 32-bit boundary field tests
  l1.m6 = 4294967295U;  // COMPLIANT - value fits in 32 bits
  l1.m6 = 4294967296UL; // NON_COMPLIANT - value does not fit in 32 bits
  l1.m6 = u8;           // COMPLIANT - widening from uint8_t
  l1.m6 = u16;          // COMPLIANT - widening from uint16_t
  l1.m6 = u32;          // COMPLIANT - same width as uint32_t
  l1.m6 = u64;          // NON_COMPLIANT - narrowing from uint64_t

  // 33-bit boundary + 1 field tests
  l1.m7 = 8589934591ULL; // COMPLIANT
  l1.m7 = 8589934592L;   // NON_COMPLIANT - value does not fit in 33 bits
  l1.m7 = 8589934592ULL; // COMPLIANT - integer constant does not satisfy
                         // conditions, but the type matches the deduced type of
                         // the bitfield (unsigned long long), so is considered
                         // compliant by the rule(!)
  l1.m7 = u8;            // COMPLIANT - widening from uint8_t
  l1.m7 = u16;           // COMPLIANT - widening from uint16_t
  l1.m7 = u32;           // COMPLIANT - widening from uint32_t
  l1.m7 = u64;           // COMPLIANT - narrowing from uint64_t

  // Signed bitfield tests
  l1.m8 = 15;  // COMPLIANT
  l1.m8 = -16; // COMPLIANT
  l1.m8 = 16;  // NON_COMPLIANT - value does not fit in signed 5-bit type
  l1.m8 = -17; // NON_COMPLIANT - value does not fit in signed 5-bit type
  l1.m8 = s8;  // COMPLIANT - same width as int8_t
  l1.m8 = s16; // NON_COMPLIANT - narrowing from int16_t

  l1.m9 = 2047;  // COMPLIANT - value fits in signed 12-bit type
  l1.m9 = -2048; // COMPLIANT - value fits in signed 12-bit type
  l1.m9 = 2048;  // NON_COMPLIANT - value does not fit in signed 12-bit type
  l1.m9 = -2049; // NON_COMPLIANT - value does not fit in signed 12-bit type
  l1.m9 = s8;    // COMPLIANT - widening from int8_t
  l1.m9 = s16;   // COMPLIANT - same width as int16_t
  l1.m9 = s32;   // NON_COMPLIANT - narrowing from int32_t

  l1.m10 = 134217727;    // COMPLIANT - value fits in signed 28-bit type
  l1.m10 = -134217728;   // COMPLIANT - value fits in signed 28-bit type
  l1.m10 = 134217728LL;  // NON_COMPLIANT - does not fit in signed 28-bit type
  l1.m10 = -134217729LL; // NON_COMPLIANT - does not fit in signed 28-bit type
  l1.m10 = s8;           // COMPLIANT - widening from int8_t
  l1.m10 = s16;          // COMPLIANT - widening from int16_t
  l1.m10 = s32;          // COMPLIANT
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

struct A {
  // first parameter to f6 with two arguments is overload-independent
  void f6(std::size_t l1, int l2) {}
  void f6(std::size_t l1, std::string l2) {}
  // Different overload, so does not conflict with f6 above
  void f6(std::int8_t l1, std::string l2, int x) {}
  // Deleted function, ignored for overload independence calculations
  void f6(float l1, float l2) = delete;
  // Not overload-independent when called with one parameter
  // Overload-independent when called with two parameters
  void f7(float l1) {}
  void f7(std::int32_t l1, int x = 1) {}
  void f8();
};

void A::f8() {
  f6(u32, "answer");       // NON_COMPLIANT - extensible, could call a global
                           // function instead - e.g. `void f6(std::uint32_t l1,
                           // std::string l2)`
  this->f6(u32, "answer"); // COMPLIANT
  this->f6(u32, 42);       // COMPLIANT
  this->f7(s16);    // NON_COMPLIANT - no widening as not overload-independent
  this->f7(s16, 2); // COMPLIANT - overload-independent, only one target
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
  // Move and copy constructors are allowed
  MyInt(MyInt const &) = default;
  MyInt(MyInt &&) = default;
};

struct ConstructorException {
  explicit ConstructorException(std::int32_t l1, std::int32_t l2 = 2) {}
};

struct NotInConstructorException {
  explicit NotInConstructorException(std::int32_t l1) {}
  NotInConstructorException(std::int16_t l1, std::int32_t l2 = 2) {}
};

void f9(MyInt l1) {}

void test_constructor_exception() {
  f9(MyInt{s8});                    // COMPLIANT
  MyInt l1{s8};                     // COMPLIANT
  f9(MyInt{s8, 10});                // NON_COMPLIANT - not covered by exception
  MyInt l2{s8, 10};                 // NON_COMPLIANT - not covered by exception
  ConstructorException l3{s8};      // COMPLIANT
  NotInConstructorException l4{s8}; // NON_COMPLIANT - ambiguous constructor
}

template <typename T> struct D {
  // Overload-independent - f10 parameters are always the same type
  void f10(T l1, int l2) {}
  void f10(T l1, std::string l2) {}
  // Not overload-independent
  template <typename S1> void f11(S1 l1, int l2) {}
  template <typename S2> void f11(S2 l1, std::string l2) {}
  void f11(std::int32_t l1, float f) {}
};

void test_template_functions() {
  D<std::uint64_t> l1;
  l1.f10(u32, "X"); // COMPLIANT - can widen, because always same type
  l1.f10(u32, 1);   // COMPLIANT - can widen, because always same type
  D<std::uint32_t> l2;
  l2.f10(u16, "X"); // COMPLIANT - can widen, because always same type
  l2.f10(u16, 1);   // COMPLIANT - can widen, because always same type
  l1.f11<std::uint64_t>(u32, "X"); // NON_COMPLIANT - not overload-independent
                                   // and not the same type as the parameter
                                   // so cannot widen - must be the same type
  l1.f11<std::int32_t>(s32, 1);    // COMPLIANT - same as specialized type
  l1.f11(s32, 0.0f);               // COMPLIANT - matches parameter type
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

// Test constructor field initializers
struct ConstructorTest {
  std::uint8_t m1;
  std::uint16_t m2;
  std::uint32_t m3;
  std::int8_t m4;
  std::int16_t m5;
  std::int32_t m6;
  float m7;
  double m8;

  // Constructor with various member initializer scenarios
  ConstructorTest(std::uint8_t l1, std::uint16_t l2, std::int8_t l3)
      : m1(l1),   // COMPLIANT - same type
        m2(l2),   // COMPLIANT - same type
        m3(l1),   // COMPLIANT - widening of id-expression
        m4(l3),   // COMPLIANT - same type
        m5(l3),   // COMPLIANT - widening of id-expression
        m6(l3),   // COMPLIANT - widening of id-expression
        m7(1.0f), // COMPLIANT - same type
        m8(1.0) { // COMPLIANT - same type
  }

  // Constructor with non-compliant initializers
  ConstructorTest(std::uint32_t l1, std::int32_t l2, float l3)
      : m1(l1),  // NON_COMPLIANT - narrowing
        m2(l1),  // NON_COMPLIANT - narrowing
        m3(l1),  // COMPLIANT - same type
        m4(l2),  // NON_COMPLIANT - narrowing and different signedness
        m5(l2),  // NON_COMPLIANT - narrowing and different signedness
        m6(l2),  // COMPLIANT - same type
        m7(l3),  // COMPLIANT - same type
        m8(l3) { // COMPLIANT - allowed to use float to initialize double
  }

  // Constructor with constant initializers
  ConstructorTest()
      : m1(100),         // COMPLIANT - constant fits
        m2(65535),       // COMPLIANT - constant fits
        m3(4294967295U), // COMPLIANT - constant fits
        m4(127),         // COMPLIANT - constant fits
        m5(32767),       // COMPLIANT - constant fits
        m6(2147483647),  // COMPLIANT - constant fits
        m7(3.14f),       // COMPLIANT - same type constant
        m8(2.718) {      // COMPLIANT - same type constant
  }

  // Constructor with non-compliant constant initializers
  ConstructorTest(int)
      : m1(300),              // NON_COMPLIANT - constant too large
        m2(70000),            // NON_COMPLIANT - constant too large
        m3(0x1'0000'0000ULL), // NON_COMPLIANT - constant too large
        m4(200),              // NON_COMPLIANT - constant too large
        m5(40000),            // NON_COMPLIANT - constant too large
        m6(0x1'0000'0000LL),  // NON_COMPLIANT - constant too large
        m7(1.0),              // NON_COMPLIANT - different size
        m8(1.0f) {            // NON_COMPLIANT - different size
  }

  // Constructor with expression initializers
  ConstructorTest(std::uint8_t l1, std::uint8_t l2, std::int8_t l3)
      : m1(l1 + l2), // NON_COMPLIANT - expression result is int
        m2(l1 + l2), // NON_COMPLIANT - expression result is int
        m3(l1 + l2), // NON_COMPLIANT - expression result is int
        m4(l3),      // COMPLIANT - widening of id-expression
        m5(l1),      // NON_COMPLIANT - different signedness
        m6(l1),      // NON_COMPLIANT - different signedness
        m7(l1),      // NON_COMPLIANT - different type category
        m8(l1) {     // NON_COMPLIANT - different type category
  }
};

void test_constructor_field_initializers() {
  std::uint8_t l1 = 42;
  std::uint16_t l2 = 1000;
  std::int8_t l3 = 10;

  ConstructorTest l4(l1, l2, l3);  // Test first constructor
  ConstructorTest l5(u32, s32, f); // Test second constructor
  ConstructorTest l6;              // Test third constructor
  ConstructorTest l7(0);           // Test fourth constructor
  ConstructorTest l8(l1, l1, l3);  // Test fifth constructor
}

// Test explicit casts
void test_explicit_casts() {
  std::uint8_t l1 = 42;
  std::uint16_t l2 = 1000;
  std::int8_t l3 = -10;
  std::int32_t l4 = -100;
  float l5 = 3.14f;
  double l6 = 2.718;

  // Explicit cast expressions are treated as expressions, not id-expressions
  u8 = static_cast<std::uint8_t>(l2);   // COMPLIANT
  u16 = static_cast<std::uint16_t>(l1); // COMPLIANT
  s8 = static_cast<std::int8_t>(l4);    // COMPLIANT
  s32 = static_cast<std::int32_t>(l3);  // COMPLIANT
  s32 = static_cast<std::int16_t>(l3);  // NON_COMPLIANT

  // Type category conversions with explicit casts
  f = static_cast<float>(l4);          // COMPLIANT
  s32 = static_cast<std::int32_t>(l5); // COMPLIANT

  // Size conversions with explicit casts
  d = static_cast<double>(l5); // COMPLIANT
  l5 = static_cast<float>(l6); // COMPLIANT

  // C-style casts (also expressions)
  u8 = (std::uint8_t)l2; // COMPLIANT
  s8 = (std::int8_t)l4;  // COMPLIANT
  f = (float)l4;         // COMPLIANT

  // Functional style casts (also expressions)
  u8 = std::uint8_t(l2); // COMPLIANT
  s8 = std::int8_t(l4);  // COMPLIANT
  f = float(l4);         // COMPLIANT

  // Const_cast (creates expressions)
  const std::uint8_t l7 = 100;
  u8 = const_cast<std::uint8_t &>(l7); // COMPLIANT

  // Reinterpret_cast (creates expressions)
  u32 = reinterpret_cast<std::uint32_t &>(l4); // COMPLIANT

  // Assignment to variables through explicit casts
  std::uint32_t l8;
  std::uint16_t l9;
  l8 = static_cast<std::uint32_t>(l9); // COMPLIANT
  l9 = static_cast<std::uint16_t>(l8); // COMPLIANT

  // Function calls with explicit casts
  f1(static_cast<std::int64_t>(l4)); // COMPLIANT
  f2(static_cast<std::int32_t>(l4)); // COMPLIANT
}