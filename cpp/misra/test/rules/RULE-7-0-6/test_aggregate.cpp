#include <cstdint>

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

// Test aggregate initialization - struct with multiple members
struct SimpleAggregate {
  std::uint8_t m1;
  std::uint16_t m2;
  std::int32_t m3;
  float m4;
};

void test_aggregate_initialization_basic() {
  // Compliant cases - exact types or constants that fit
  SimpleAggregate l1{42, 1000, -50, 3.14f};         // COMPLIANT
  SimpleAggregate l2{u8, u16, s32, f};              // COMPLIANT
  SimpleAggregate l3{255, 65535, 2147483647, 0.0f}; // COMPLIANT

  // Non-compliant cases - type violations
  SimpleAggregate l4{u16, u8, s32, // NON_COMPLIANT - narrowing u16 to uint8_t
                     f};
  SimpleAggregate l5{u8, u32, s32, // NON_COMPLIANT - narrowing u32 to uint16_t
                     f};
  SimpleAggregate l6{u8, u16, u32, f}; // NON_COMPLIANT - different signedness
  SimpleAggregate l7{u8, u16, s32,
                     s32}; // NON_COMPLIANT - different type category

  // Constants that don't fit
  SimpleAggregate l8{256, 65536,   // NON_COMPLIANT - constants don't fit
                     2147483648LL, // NON_COMPLIANT - constants don't fit
                     0.0f};

  // Widening of id-expressions is allowed
  SimpleAggregate l9{u8, u8, s8, f}; // COMPLIANT - widening allowed
}

// Test aggregate initialization - arrays
void test_aggregate_initialization_arrays() {
  // Basic arrays
  std::uint8_t l1[3]{10, 20, 30};    // COMPLIANT
  std::uint8_t l2[3]{u8, u8, u8};    // COMPLIANT
  std::uint8_t l3[3]{300, 400, 500}; // NON_COMPLIANT - constants don't fit
  std::uint8_t l4[3]{s8, s8, s8};    // NON_COMPLIANT - signedness mismatch
  std::uint8_t l5[3]{u16, u16, u16}; // NON_COMPLIANT - narrowing

  // Multi-dimensional arrays
  std::int16_t l6[2][2]{{1, 2}, {3, 4}};         // COMPLIANT
  std::int16_t l7[2][2]{{s8, s8}, {s8, s8}};     // COMPLIANT - widening allowed
  std::int16_t l8[2][2]{{s32, s32}, {s32, s32}}; // NON_COMPLIANT - narrowing
  std::int16_t l9[2][2]{{u8, u8},  // NON_COMPLIANT - signedness mismatch
                        {u8, u8}}; // NON_COMPLIANT - signedness mismatch
}

// Test aggregate initialization - nested structs
struct NestedAggregate {
  SimpleAggregate m1;
  std::uint32_t m2;
};

void test_aggregate_initialization_nested() {
  // Compliant nested initialization
  NestedAggregate l1{{10, 100, -5, 1.0f}, 500}; // COMPLIANT
  NestedAggregate l2{{u8, u16, s32, f}, u32};   // COMPLIANT

  // Non-compliant nested initialization
  NestedAggregate l3{
      {u16, u8, s32, f}, // NON_COMPLIANT - narrowing in nested struct
      u32};
  NestedAggregate l4{
      {u8, u16, s32, f},
      s32}; // NON_COMPLIANT - signedness mismatch in outer member
}

// Test aggregate initialization - struct with bit-fields
struct BitfieldAggregate {
  std::uint32_t m1 : 8;
  std::uint32_t m2 : 16;
  std::int32_t m3 : 12;
};

void test_aggregate_initialization_bitfields() {
  // Compliant cases
  BitfieldAggregate l1{100, 30000, -500}; // COMPLIANT
  BitfieldAggregate l2{u8, u16, s16};     // COMPLIANT - appropriate sizes

  // Non-compliant cases
  BitfieldAggregate l3{300, 70000, 5000}; // NON_COMPLIANT - constants don't fit
  BitfieldAggregate l4{u16, u32, s32};    // NON_COMPLIANT - narrowing
}

// Test aggregate initialization with designated initializers (C++20 feature,
// but test for basic cases)
void test_aggregate_initialization_designated() {
  // Note: Designated initializers are C++20, but we can test basic aggregate
  // init patterns
  SimpleAggregate l1{.m1 = 10, .m2 = 100, .m3 = -5, .m4 = 1.0f}; // COMPLIANT
  SimpleAggregate l2{.m1 = u8, .m2 = u16, .m3 = s32, .m4 = f};   // COMPLIANT
  SimpleAggregate l3{.m1 = u16, // NON_COMPLIANT - type violation
                     .m2 = u8,
                     .m3 = s32,
                     .m4 = f};
}