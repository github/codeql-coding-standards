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
  l1 &l2;  // NON_COMPLIANT - u8 & u8 -> signed int
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

void test_shift_operations() {
  std::uint8_t l1 = 5;
  std::uint16_t l2 = 100;
  std::uint32_t l3 = 1000;
  std::int16_t l4;

  l1 << 2;  // NON_COMPLIANT - l1 -> signed int
  l1 >> 1;  // NON_COMPLIANT - l1 -> signed int
  l2 << 2;  // NON_COMPLIANT - l2 -> signed int
  l2 >> 1;  // NON_COMPLIANT - l2 -> signed int
  l3 << 2;  // COMPLIANT
  l3 >> 1;  // COMPLIANT
  l3 << l1; // NON_COMPLIANT - l1 -> signed int
  l3 >> l1; // NON_COMPLIANT - l1 -> signed int
  l3 << l4; // COMPLIANT
  l3 >> l4; // COMPLIANT

  l1 <<= 2;  // NON_COMPLIANT - l1 -> signed int
  l1 >>= 1;  // NON_COMPLIANT - l1 -> signed int
  l2 <<= 2;  // NON_COMPLIANT - l2 -> signed int
  l2 >>= 1;  // NON_COMPLIANT - l2 -> signed int
  l3 <<= 2;  // COMPLIANT
  l3 >>= 1;  // COMPLIANT
  l3 <<= l1; // NON_COMPLIANT - l1 -> signed int
  l3 >>= l1; // NON_COMPLIANT - l1 -> signed int
  l3 <<= l4; // COMPLIANT
  l3 >>= l4; // COMPLIANT
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

void test_logical_operators() {
  std::uint8_t l1 = 5;
  std::uint8_t l2 = 10;
  std::uint16_t l3 = 100;
  std::int8_t l4 = -5;
  bool l5 = true;

  l1 &&l2;  // COMPLIANT - rule does not apply to logical operators
  l1 || l2; // COMPLIANT - rule does not apply to logical operators
  l1 &&l3;  // COMPLIANT - rule does not apply to logical operators
  l4 &&l1;  // COMPLIANT - rule does not apply to logical operators
  l5 &&l1;  // COMPLIANT - rule does not apply to logical operators
  l1 &&l5;  // COMPLIANT - rule does not apply to logical operators
}

void test_mixed_signed_unsigned_arithmetic() {
  std::int8_t l1 = -5;
  std::uint8_t l2 = 10;
  std::int16_t l3 = -100;
  std::uint16_t l4 = 200;

  l1 + l2; // NON_COMPLIANT - l1 and l2 -> signed int
  l1 - l2; // NON_COMPLIANT - l1 and l2 -> signed int
  l1 *l2;  // NON_COMPLIANT - l1 and l2 -> signed int
  l1 / l2; // NON_COMPLIANT - l1 and l2 -> signed int
  l1 % l2; // NON_COMPLIANT - l1 and l2 -> signed int
  l1 &l2;  // NON_COMPLIANT - l1 and l2 -> signed int
  l1 | l2; // NON_COMPLIANT - l1 and l2 -> signed int
  l1 ^ l2; // NON_COMPLIANT - l1 and l2 -> signed int

  l3 + l4; // NON_COMPLIANT - l3 and l4 -> signed int
  l3 - l4; // NON_COMPLIANT - l3 and l4 -> signed int
  l3 *l4;  // NON_COMPLIANT - l3 and l4 -> signed int

  l1 < l2;  // NON_COMPLIANT - l1 and l2 -> signed int
  l1 > l2;  // NON_COMPLIANT - l1 and l2 -> signed int
  l3 == l4; // NON_COMPLIANT - l3 and l4 -> signed int
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

void test_pointer_arithmetic() {
  int l1[10];
  std::uint8_t l2 = 5;
  std::uint16_t l3 = 2;
  std::int8_t l4 = 3;
  std::int32_t l5 = 1;
  int *l6 = l1;

  l1 + l2; // COMPLIANT - rule does not apply to pointer arithmetic
  l1 + l3; // COMPLIANT - rule does not apply to pointer arithmetic
  l1 + l4; // COMPLIANT - rule does not apply to pointer arithmetic
  l1 + l5; // COMPLIANT - rule does not apply to pointer arithmetic
  l6 + l2; // COMPLIANT - rule does not apply to pointer arithmetic
  l6 + l3; // COMPLIANT - rule does not apply to pointer arithmetic

  l1 - l2; // COMPLIANT - rule does not apply to pointer arithmetic
  l6 - l3; // COMPLIANT - rule does not apply to pointer arithmetic

  l6 - l1; // COMPLIANT - rule does not apply to pointer arithmetic
}

void test_pointer_assignment_arithmetic() {
  int l1[10];
  std::uint8_t l2 = 5;
  std::uint16_t l3 = 2;
  std::int8_t l4 = 3;
  int *l5 = l1;

  l5 += l2; // COMPLIANT - rule does not apply to pointer arithmetic
  l5 += l3; // COMPLIANT - rule does not apply to pointer arithmetic
  l5 += l4; // COMPLIANT - rule does not apply to pointer arithmetic

  l5 -= l2; // COMPLIANT - rule does not apply to pointer arithmetic
  l5 -= l3; // COMPLIANT - rule does not apply to pointer arithmetic
  l5 -= l4; // COMPLIANT - rule does not apply to pointer arithmetic
}

// Enum types for testing
enum UnscopedEnum { VALUE1, VALUE2, VALUE3 };
enum class ScopedEnum { VALUE1, VALUE2, VALUE3 };
enum UnscopedEnumExplicit : std::uint8_t {
  EXPLICIT_VALUE1 = 1,
  EXPLICIT_VALUE2 = 2
};
enum class ScopedEnumExplicit : std::uint8_t {
  EXPLICIT_VALUE1 = 1,
  EXPLICIT_VALUE2 = 2
};

void test_enum_types() {
  UnscopedEnum l1 = VALUE1;
  UnscopedEnum l2 = VALUE2;
  UnscopedEnumExplicit l3 = EXPLICIT_VALUE1;
  UnscopedEnumExplicit l4 = EXPLICIT_VALUE2;
  ScopedEnum l5 = ScopedEnum::VALUE1;
  ScopedEnumExplicit l6 = ScopedEnumExplicit::EXPLICIT_VALUE1;
  std::uint8_t l7 = 5;
  std::uint32_t l8 = 10;

  // Unscoped enum without explicit underlying type - not considered numeric
  // type
  l1 + l2; // COMPLIANT - rule does not apply
  l1 *l2;  // COMPLIANT - rule does not apply
  l1 &l2;  // COMPLIANT - rule does not apply

  // Unscoped enum with explicit underlying type - considered numeric type
  l3 + l4; // NON_COMPLIANT - uint8_t + uint8_t -> signed int
  l3 *l4;  // NON_COMPLIANT - uint8_t * uint8_t -> signed int
  l3 &l4;  // NON_COMPLIANT - uint8_t & uint8_t -> signed int
  l3 - l4; // NON_COMPLIANT - uint8_t - uint8_t -> signed int
  l3 | l4; // NON_COMPLIANT - uint8_t | uint8_t -> signed int
  l3 ^ l4; // NON_COMPLIANT - uint8_t ^ uint8_t -> signed int

  // Mixed enum and integer arithmetic
  l3 + l7; // NON_COMPLIANT - uint8_t + uint8_t -> signed int
  l3 *l7;  // NON_COMPLIANT - uint8_t * uint8_t -> signed int
  l7 - l3; // NON_COMPLIANT - uint8_t - uint8_t -> signed int

  l3 + l8; // COMPLIANT - uint8_t -> signed int (matches l8)
  l8 *l3;  // COMPLIANT - uint8_t -> signed int (matches l8)

  // Unary operations on enum with explicit underlying type
  ~l3; // NON_COMPLIANT - uint8_t -> signed int
  -l3; // NON_COMPLIANT - uint8_t -> signed int
  +l3; // NON_COMPLIANT - uint8_t -> signed int

  // Scoped enums - not considered numeric type regardless of underlying type
  static_cast<int>(l5) +
      static_cast<int>(ScopedEnum::VALUE2); // COMPLIANT - rule does not apply
                                            // to explicit casts
  static_cast<std::uint8_t>(l6) +           // NON_COMPLIANT
      static_cast<std::uint8_t>(            // NON_COMPLIANT
          ScopedEnumExplicit::EXPLICIT_VALUE2);

  // Comparison operations with enum
  l3 > l4;  // NON_COMPLIANT - uint8_t > uint8_t -> signed int
  l3 == l4; // NON_COMPLIANT - uint8_t == uint8_t -> signed int
  l3 != l7; // NON_COMPLIANT - uint8_t != uint8_t -> signed int

  // Shift operations with enum
  l3 << 1; // NON_COMPLIANT - uint8_t -> signed int
  l3 >> 1; // NON_COMPLIANT - uint8_t -> signed int

  // Conditional operator with enum
  true ? l3 : l4; // COMPLIANT - same types, no conversion
  true ? l3 : l8; // COMPLIANT - same underlying types, no conversion
}

#define A 100LL  // intmax_t
#define B 200LL  // intmax_t
#define C 300ULL // uintmax_t
#define D 400ULL // uintmax_t

#if A + B > 250 // COMPLIANT - both intmax_t, no conversion
;
#elif C + D < 800 // COMPLIANT - both uintmax_t, no conversion
;
#endif

#define SIGNED_MAX 9223372036854775807LL // intmax_t
#define UNSIGNED_VAL 1ULL                // uintmax_t

#if SIGNED_MAX + UNSIGNED_VAL > 0 // NON_COMPLIANT[FALSE_NEGATIVE]
// intmax_t + uintmax_t → both converted to uintmax_t
// This changes SIGNED_MAX from signed to unsigned
;
#endif
