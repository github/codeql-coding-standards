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

// Test cv-qualified types
void test_cv_qualified_const() {
  const std::uint8_t l1 = 42;     // COMPLIANT
  const std::uint16_t l2 = 1000;  // COMPLIANT
  const std::uint32_t l3 = 50000; // COMPLIANT
  const std::int8_t l4 = -5;      // COMPLIANT
  const std::int16_t l5 = -1000;  // COMPLIANT
  const std::int32_t l6 = -50000; // COMPLIANT
  const float l7 = 3.14f;         // COMPLIANT
  const double l8 = 2.718;        // COMPLIANT

  // Widening of const id-expressions - allowed
  // Also allowed because the integer constant expressions are within the range
  u16 = l1; // COMPLIANT
  u32 = l1; // COMPLIANT
  u32 = l2; // COMPLIANT
  s16 = l4; // COMPLIANT
  s32 = l4; // COMPLIANT
  s32 = l5; // COMPLIANT

  // Narrowing of const id-expressions - not allowed
  u8 = l2; // NON_COMPLIANT
  u8 = l3; // NON_COMPLIANT
  // Permitted because the integer constant expression is within the range
  u16 = l3; // COMPLIANT
  s8 = l5;  // NON_COMPLIANT
  s8 = l6;  // NON_COMPLIANT
  s16 = l6; // NON_COMPLIANT

  // Incorrect signedness conversions, and the integer constant
  // expressions are not in the range of the target type (as they are all
  // negative)
  u8 = l4;  // NON_COMPLIANT
  u16 = l5; // NON_COMPLIANT
  u32 = l6; // NON_COMPLIANT
  // These are signedness violations, but as they are integer constant
  // expressions within range they are allowed
  s8 = l1;  // COMPLIANT
  s16 = l2; // COMPLIANT
  s32 = l3; // COMPLIANT

  // Type category errors (int to float)
  s32 = l7; // NON_COMPLIANT
  s32 = l8; // NON_COMPLIANT
  // These are not type category errors, as they are integer constant
  // expressions whose value fits within both floating point types, as the range
  // is infinite
  f = l4; // COMPLIANT
  f = l5; // COMPLIANT
  f = l6; // COMPLIANT
  d = l4; // COMPLIANT
  d = l5; // COMPLIANT
  d = l6; // COMPLIANT

  // Size violations within same type category with const
  f = l8; // NON_COMPLIANT
  d = l7; // COMPLIANT
}

void test_cv_qualified_volatile() {
  volatile std::uint8_t l1 = 42;
  volatile std::uint16_t l2 = 1000;
  volatile std::uint32_t l3 = 50000;
  volatile std::int8_t l4 = -5;
  volatile std::int16_t l5 = -1000;
  volatile std::int32_t l6 = -50000;
  volatile float l7 = 3.14f;
  volatile double l8 = 2.718;

  // Widening of volatile id-expressions - allowed
  u16 = l1; // COMPLIANT
  u32 = l1; // COMPLIANT
  u32 = l2; // COMPLIANT
  s16 = l4; // COMPLIANT
  s32 = l4; // COMPLIANT
  s32 = l5; // COMPLIANT

  // Narrowing of volatile id-expressions - not allowed
  u8 = l2;  // NON_COMPLIANT
  u8 = l3;  // NON_COMPLIANT
  u16 = l3; // NON_COMPLIANT
  s8 = l5;  // NON_COMPLIANT
  s8 = l6;  // NON_COMPLIANT
  s16 = l6; // NON_COMPLIANT

  // Signedness violations with volatile
  u8 = l4;  // NON_COMPLIANT
  u16 = l5; // NON_COMPLIANT
  u32 = l6; // NON_COMPLIANT
  s8 = l1;  // NON_COMPLIANT
  s16 = l2; // NON_COMPLIANT
  s32 = l3; // NON_COMPLIANT

  // Type category violations with volatile
  s32 = l7; // NON_COMPLIANT
  s32 = l8; // NON_COMPLIANT
  f = l4;   // NON_COMPLIANT
  f = l5;   // NON_COMPLIANT
  f = l6;   // NON_COMPLIANT
  d = l4;   // NON_COMPLIANT
  d = l5;   // NON_COMPLIANT
  d = l6;   // NON_COMPLIANT

  // Size violations within same type category with volatile
  f = l8; // NON_COMPLIANT
  d = l7; // COMPLIANT
}

void test_cv_qualified_const_volatile() {
  const volatile std::uint8_t l1 = 42;
  const volatile std::uint16_t l2 = 1000;
  const volatile std::uint32_t l3 = 50000;
  const volatile std::int8_t l4 = -5;
  const volatile std::int16_t l5 = -1000;
  const volatile std::int32_t l6 = -50000;
  const volatile float l7 = 3.14f;
  const volatile double l8 = 2.718;

  // Widening of const volatile id-expressions - allowed
  u16 = l1; // COMPLIANT
  u32 = l1; // COMPLIANT
  u32 = l2; // COMPLIANT
  s16 = l4; // COMPLIANT
  s32 = l4; // COMPLIANT
  s32 = l5; // COMPLIANT

  // Narrowing of const volatile id-expressions - not allowed
  u8 = l2;  // NON_COMPLIANT
  u8 = l3;  // NON_COMPLIANT
  u16 = l3; // NON_COMPLIANT
  s8 = l5;  // NON_COMPLIANT
  s8 = l6;  // NON_COMPLIANT
  s16 = l6; // NON_COMPLIANT

  // Signedness violations with const volatile
  u8 = l4;  // NON_COMPLIANT
  u16 = l5; // NON_COMPLIANT
  u32 = l6; // NON_COMPLIANT
  s8 = l1;  // NON_COMPLIANT
  s16 = l2; // NON_COMPLIANT
  s32 = l3; // NON_COMPLIANT

  // Type category violations with const volatile
  s32 = l7; // NON_COMPLIANT
  s32 = l8; // NON_COMPLIANT
  f = l4;   // NON_COMPLIANT
  f = l5;   // NON_COMPLIANT
  f = l6;   // NON_COMPLIANT
  d = l4;   // NON_COMPLIANT
  d = l5;   // NON_COMPLIANT
  d = l6;   // NON_COMPLIANT

  // Size violations within same type category with const volatile
  f = l8; // NON_COMPLIANT
  d = l7; // COMPLIANT
}

// Test cv-qualified references
void test_cv_qualified_references() {
  std::uint8_t l1 = 42;
  std::uint16_t l2 = 1000;
  std::int8_t l3 = -5;
  float l4 = 3.14f;

  const std::uint8_t &l5 = l1;
  const std::uint16_t &l6 = l2;
  const std::int8_t &l7 = l3;
  const float &l8 = l4;

  volatile std::uint8_t &l9 = l1;
  volatile std::uint16_t &l10 = l2;
  volatile std::int8_t &l11 = l3;
  volatile float &l12 = l4;

  const volatile std::uint8_t &l13 = l1;
  const volatile std::uint16_t &l14 = l2;
  const volatile std::int8_t &l15 = l3;
  const volatile float &l16 = l4;

  // Widening through cv-qualified references - allowed
  u16 = l5;  // COMPLIANT
  u32 = l5;  // COMPLIANT
  u32 = l6;  // COMPLIANT
  s16 = l7;  // COMPLIANT
  s32 = l7;  // COMPLIANT
  u16 = l9;  // COMPLIANT
  u32 = l9;  // COMPLIANT
  u32 = l10; // COMPLIANT
  s16 = l11; // COMPLIANT
  s32 = l11; // COMPLIANT
  u16 = l13; // COMPLIANT
  u32 = l13; // COMPLIANT
  u32 = l14; // COMPLIANT
  s16 = l15; // COMPLIANT
  s32 = l15; // COMPLIANT

  // Narrowing through cv-qualified references - not allowed
  u8 = l6;  // NON_COMPLIANT
  u8 = l10; // NON_COMPLIANT
  u8 = l14; // NON_COMPLIANT

  // Signedness violations through cv-qualified references
  s8 = l5;  // NON_COMPLIANT
  u8 = l7;  // NON_COMPLIANT
  s8 = l9;  // NON_COMPLIANT
  u8 = l11; // NON_COMPLIANT
  s8 = l13; // NON_COMPLIANT
  u8 = l15; // NON_COMPLIANT

  // Type category violations through cv-qualified references
  s32 = l8;  // NON_COMPLIANT
  s32 = l12; // NON_COMPLIANT
  s32 = l16; // NON_COMPLIANT
  f = l3;    // NON_COMPLIANT
  f = l7;    // NON_COMPLIANT
  f = l11;   // NON_COMPLIANT
  f = l15;   // NON_COMPLIANT
}

// Test cv-qualified function parameters
void f15(const std::uint32_t l1) {}
void f16(volatile std::int64_t l1) {}
void f17(const volatile std::uint16_t l1) {}

void test_cv_qualified_function_parameters() {
  const std::uint8_t l1 = 42;
  volatile std::uint16_t l2 = 1000;
  const volatile std::int8_t l3 = -5;

  f15(l1); // NON_COMPLIANT
  f15(l2); // NON_COMPLIANT
  f16(l3); // NON_COMPLIANT
  f17(l1); // NON_COMPLIANT
  f17(l2); // COMPLIANT
  f17(l3); // NON_COMPLIANT
}

// Test cv-qualified static and namespace variables
namespace CVNamespace {
const std::uint8_t g3 = 42;
volatile std::uint16_t g4 = 1000;
const volatile std::int8_t g5 = -5;
} // namespace CVNamespace

struct CVStruct {
  static const std::uint8_t s3;
  static volatile std::uint16_t s4;
  static const volatile std::int8_t s5;
};

const std::uint8_t CVStruct::s3 = 42;
volatile std::uint16_t CVStruct::s4 = 1000;
const volatile std::int8_t CVStruct::s5 = -5;

void test_cv_qualified_static_and_namespace() {
  // Widening of cv-qualified namespace and static variables - allowed
  u16 = CVNamespace::g3; // COMPLIANT
  u32 = CVNamespace::g3; // COMPLIANT
  u32 = CVNamespace::g4; // COMPLIANT
  s16 = CVNamespace::g5; // COMPLIANT
  s32 = CVNamespace::g5; // COMPLIANT

  u16 = CVStruct::s3; // COMPLIANT
  u32 = CVStruct::s3; // COMPLIANT
  u32 = CVStruct::s4; // COMPLIANT
  s16 = CVStruct::s5; // COMPLIANT
  s32 = CVStruct::s5; // COMPLIANT

  // Narrowing of cv-qualified namespace and static variables - not allowed
  u8 = CVNamespace::g4; // NON_COMPLIANT
  s8 = CVNamespace::g5; // COMPLIANT - constant fits
  u8 = CVStruct::s4;    // NON_COMPLIANT
  s8 = CVStruct::s5;    // COMPLIANT - constant fits

  // Signedness violations with cv-qualified namespace and static variables
  s8 = CVNamespace::g3;  // COMPLIANT - constant expression
  u16 = CVNamespace::g5; // NON_COMPLIANT
  s8 = CVStruct::s3;     // COMPLIANT - constant expression
  u16 = CVStruct::s5;    // NON_COMPLIANT
}

// Test cv-qualified bitfields
struct CVBitfieldStruct {
  const std::uint32_t m11 : 8;
  volatile std::uint32_t m12 : 16;
  const volatile std::int32_t m13 : 12;
};

void test_cv_qualified_bitfields() {
  CVBitfieldStruct l1{100, 30000, -500}; // COMPLIANT

  // CV-qualified bitfields follow same rules as regular bitfields
  CVBitfieldStruct l2{300, 70000, 3000}; // NON_COMPLIANT
  l2.m12 = 70000;                        // NON_COMPLIANT

  CVBitfieldStruct l3{u8, u16, s16}; // COMPLIANT
  l1.m12 = u16;                      // COMPLIANT

  CVBitfieldStruct l4{u16, u32, s32}; // NON_COMPLIANT
}

// Test cv-qualified enums
enum CVColour : std::uint16_t { cv_red, cv_green, cv_blue };

void test_cv_qualified_enums() {
  const CVColour l1 = cv_red;
  volatile CVColour l2 = cv_green;
  const volatile CVColour l3 = cv_blue;

  u8 = cv_red;  // COMPLIANT
  u32 = cv_red; // COMPLIANT
  u8 = l1;      // COMPLIANT - constant fits in uint8_t
  u32 = l1;     // COMPLIANT
  u8 = l2;      // NON_COMPLIANT
  u32 = l2;     // COMPLIANT
  u8 = l3;      // NON_COMPLIANT
  u32 = l3;     // COMPLIANT
}

// Test cv-qualified expressions with operators
void test_cv_qualified_expressions() {
  const std::uint8_t l1 = 10;
  volatile std::uint8_t l2 = 20;
  const volatile std::uint8_t l3 = 30;

  // Expressions with cv-qualified operands still follow expression rules
  u8 = l1 + l2;  // NON_COMPLIANT
  u8 = l1 + l3;  // NON_COMPLIANT
  u8 = l2 + l3;  // NON_COMPLIANT
  s32 = l1 + l2; // COMPLIANT
  s32 = l1 + l3; // COMPLIANT
  s32 = l2 + l3; // COMPLIANT

  // Parenthesized cv-qualified expressions are not id-expressions
  u32 = (l1); // COMPLIANT - constant expression fits
  u32 = (l2); // NON_COMPLIANT
  u32 = (l3); // NON_COMPLIANT
}

// Test cv-qualified aggregate initialization
struct CVAggregate {
  const std::uint8_t m1;
  volatile std::uint16_t m2;
  const volatile std::int32_t m3;
};

void test_cv_qualified_aggregate_initialization() {
  const std::uint8_t l1 = 42;
  volatile std::uint16_t l2 = 1000;
  const volatile std::int8_t l3 = -5;

  // CV-qualified aggregate members follow same rules
  CVAggregate l4{10, 100, -50};   // COMPLIANT
  CVAggregate l5{l1, l2, l3};     // COMPLIANT
  CVAggregate l6{300, 70000, l3}; // NON_COMPLIANT
}