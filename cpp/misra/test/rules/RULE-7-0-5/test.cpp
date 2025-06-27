#include <cstdint>

// Global variables for testing
std::uint8_t g1 = 5;
std::uint8_t g2 = 10;
std::uint16_t g3 = 100;
std::uint32_t g4 = 1000;
std::int8_t g5 = -5;
std::int32_t g6 = -1000;
float g7 = 3.14f;

constexpr std::int32_t f1(std::int32_t i) { return i * i; }

void test_binary_arithmetic_operations() {
  std::uint8_t l1 = 5;
  std::uint8_t l2 = 10;
  std::uint16_t l3 = 100;
  std::uint32_t l4 = 1000;
  std::int8_t l5 = -5;
  std::int32_t l6 = -1000;

  l1 + l2; // NON_COMPLIANT - u8 + u8 -> signed int
  l1 *l2;  // NON_COMPLIANT - u8 * u8 -> signed int
  l1 - l2; // NON_COMPLIANT - u8 - u8 -> signed int
  l1 / l2; // NON_COMPLIANT - u8 / u8 -> signed int
  l1 % l2; // NON_COMPLIANT - u8 % u8 -> signed int
  l1 & l2; // NON_COMPLIANT - u8 & u8 -> signed int
  l1 | l2; // NON_COMPLIANT - u8 | u8 -> signed int
  l1 ^ l2; // NON_COMPLIANT - u8 ^ u8 -> signed int

  static_cast<std::uint32_t>(l1) + l2; // COMPLIANT - l2 -> unsigned int
  l1 + static_cast<std::uint32_t>(l2); // COMPLIANT - l1 -> unsigned int

  l6 *l5;  // COMPLIANT - l5 -> signed int
  l4 / l1; // COMPLIANT - l1 -> unsigned int
}

void test_assignment_operations() {
  std::uint8_t l1 = 5;
  std::uint8_t l2 = 10;
  std::uint32_t l3 = 1000;

  l1 += l2; // NON_COMPLIANT - same as l1 + l2
  l1 -= l2; // NON_COMPLIANT - same as l1 - l2
  l1 *= l2; // NON_COMPLIANT - same as l1 * l2
  l1 /= l2; // NON_COMPLIANT - same as l1 / l2
  l1 %= l2; // NON_COMPLIANT - same as l1 % l2
  l1 &= l2; // NON_COMPLIANT - same as l1 & l2
  l1 |= l2; // NON_COMPLIANT - same as l1 | l2
  l1 ^= l2; // NON_COMPLIANT - same as l1 ^ l2

  l1 += static_cast<std::uint32_t>(l2); // COMPLIANT - l1 -> unsigned int
  l1 += l3;                             // COMPLIANT - l1 -> unsigned int
}

void test_comparison_operations() {
  std::int32_t l1 = -1000;
  std::uint32_t l2 = 1000;
  std::uint8_t l3 = 5;
  std::uint16_t l4 = 100;

  l1 > l2;  // NON_COMPLIANT - l1 -> unsigned int
  l1 < l2;  // NON_COMPLIANT - l1 -> unsigned int
  l1 >= l2; // NON_COMPLIANT - l1 -> unsigned int
  l1 <= l2; // NON_COMPLIANT - l1 -> unsigned int
  l1 == l2; // NON_COMPLIANT - l1 -> unsigned int
  l1 != l2; // NON_COMPLIANT - l1 -> unsigned int

  l3 > l4; // NON_COMPLIANT - l3 and l4 -> signed int
  l3 < l4; // NON_COMPLIANT - l3 and l4 -> signed int
}

void test_conditional_operator() {
  bool l1 = true;
  std::uint8_t l2 = 5;
  std::uint8_t l3 = 10;
  std::uint16_t l4 = 100;

  l1 ? l2 : l3; // COMPLIANT - no conversion
  l1 ? l2 : l4; // NON_COMPLIANT - l2 and l4 -> signed int
}

void test_shift_operations() {
  std::uint8_t l1 = 5;
  std::uint32_t l2 = 1000;

  l1 << 2; // NON_COMPLIANT - l1 -> signed int
  l1 >> 1; // NON_COMPLIANT - l1 -> signed int
  l2 << 2; // COMPLIANT
  l2 >> 1; // COMPLIANT
}

void test_unary_operations() {
  std::uint8_t l1 = 5;
  std::uint32_t l2 = 1000;
  std::int8_t l3 = -5;

  ~l1; // NON_COMPLIANT - l1 -> signed int
  ~l2; // COMPLIANT
  -l1; // NON_COMPLIANT - l1 -> signed int
  -l3; // COMPLIANT - l3 is signed
  +l1; // NON_COMPLIANT - l1 -> signed int
}

void test_increment_decrement() {
  std::uint8_t l1 = 5;
  std::uint16_t l2 = 100;

  l1++; // COMPLIANT - rule does not apply
  ++l1; // COMPLIANT - rule does not apply
  l1--; // COMPLIANT - rule does not apply
  --l1; // COMPLIANT - rule does not apply
  l2++; // COMPLIANT - rule does not apply
  ++l2; // COMPLIANT - rule does not apply
}

void test_array_subscript() {
  int l1[10];
  std::uint8_t l2 = 5;

  l1[l2]; // COMPLIANT - rule does not apply
}

void test_exception_compile_time_constants() {
  std::uint32_t l1 = 1000;
  float l2 = 3.14f;
  std::int32_t l3 = 5;

  l1 - 1;        // COMPLIANT - exception #1
  l1 + 42;       // COMPLIANT - exception #1
  l2 += 1;       // COMPLIANT - exception #2
  l2 += 0x10001; // COMPLIANT - exception #2
  l3 + f1(10);   // COMPLIANT - exception #1
  l2 + f1(10);   // COMPLIANT - exception #2
}

void test_floating_point_conversions() {
  float l1;
  std::uint32_t l2;

  l1 += l2; // NON_COMPLIANT - l2 -> floating
  l1 *= l2; // NON_COMPLIANT - l2 -> floating
  l1 /= l2; // NON_COMPLIANT - l2 -> floating
}