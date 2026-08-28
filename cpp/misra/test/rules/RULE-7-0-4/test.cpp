#include <climits>
#include <cstdint>

void test_binary_bitwise_operators_unsigned_operands() {
  std::uint32_t u32a = 0x12345678U;
  std::uint32_t u32b = 0x87654321U;
  std::int32_t s32a = 0x12345678;
  std::int32_t s32b = 0x87654321;

  u32a &u32b;  // COMPLIANT
  u32a | u32b; // COMPLIANT
  u32a ^ u32b; // COMPLIANT

  s32a &s32b;  // NON_COMPLIANT
  s32a | s32b; // NON_COMPLIANT
  s32a ^ s32b; // NON_COMPLIANT

  s32a &u32b;  // NON_COMPLIANT
  u32a | s32b; // NON_COMPLIANT
}

void test_compound_assignment_bitwise_operators() {
  std::uint32_t u32 = 0x12345678U;
  std::int32_t s32 = 0x12345678;

  u32 &= 0xFFFFU; // COMPLIANT
  u32 |= 0x1000U; // COMPLIANT
  u32 ^= 0x5555U; // COMPLIANT

  s32 &= 0xFFFF; // NON_COMPLIANT
  s32 |= 0x1000; // NON_COMPLIANT
  s32 ^= 0x5555; // NON_COMPLIANT
}

void test_bit_complement_operator() {
  std::uint32_t u32 = 0x12345678U;
  std::uint8_t u8 = 0x55U;
  std::int32_t s32 = 0x12345678;

  ~u32; // COMPLIANT
  ~u8;  // COMPLIANT
  ~s32; // NON_COMPLIANT
}

void test_shift_operators_left_operand_type() {
  std::uint32_t u32 = 0x12345678U;
  std::uint8_t u8 = 2U;
  std::int32_t s32 = 0x12345678;

  1U << u8;  // COMPLIANT
  1U << 31;  // COMPLIANT
  u32 << 2U; // COMPLIANT

  1 << u8;   // NON_COMPLIANT
  s32 << 2U; // NON_COMPLIANT
}

void test_shift_operators_with_promotion() {
  std::uint8_t u8 = 1U;
  std::uint16_t u16 = 2U;

  static_cast<std::uint16_t>(u8 + u16) << 2U; // COMPLIANT
  (u8 + u16) << 2U;                           // NON_COMPLIANT
}

void test_shift_operators_right_operand_unsigned() {
  std::uint32_t u32 = 0x12345678U;
  std::uint8_t u8 = 2U;
  std::int8_t s8 = 2;

  u32 << u8; // COMPLIANT
  u32 >> u8; // COMPLIANT

  u32 << s8; // NON_COMPLIANT
  u32 >> s8; // NON_COMPLIANT
}

void test_shift_operators_right_operand_constant_range() {
  std::uint32_t u32 = 0x12345678U;

  u32 << 0;  // COMPLIANT
  u32 << 31; // COMPLIANT
  u32 >> 15; // COMPLIANT

  u32 << 32; // NON_COMPLIANT
  u32 << 64; // NON_COMPLIANT
  u32 >> 32; // NON_COMPLIANT
}

void test_shift_operators_negative_right_operand() {
  std::uint32_t u32 = 0x12345678U;

  u32 << -1; // NON_COMPLIANT
  u32 << -5; // NON_COMPLIANT
  u32 >> -1; // NON_COMPLIANT
  u32 >> -3; // NON_COMPLIANT
}

void test_compound_assignment_shift_operators() {
  std::uint32_t u32 = 0x12345678U;
  std::uint8_t u8 = 2U;
  std::int32_t s32 = 0x12345678;
  std::int8_t s8 = 2;

  // Unsigned left operand with unsigned right operand
  u32 <<= u8; // COMPLIANT
  u32 >>= u8; // COMPLIANT

  // Unsigned left operand with constant right operand in valid range
  u32 <<= 0;  // COMPLIANT
  u32 <<= 31; // COMPLIANT
  u32 >>= 15; // COMPLIANT

  // Signed left operand
  s32 <<= u8; // NON_COMPLIANT
  s32 >>= u8; // NON_COMPLIANT
  s32 <<= 2;  // NON_COMPLIANT
  s32 >>= 2;  // NON_COMPLIANT

  // Unsigned left operand with signed right operand
  u32 <<= s8; // NON_COMPLIANT
  u32 >>= s8; // NON_COMPLIANT

  // Right operand out of range
  u32 <<= 32; // NON_COMPLIANT
  u32 <<= 64; // NON_COMPLIANT
  u32 >>= 32; // NON_COMPLIANT

  // Negative right operand
  u32 <<= -1; // NON_COMPLIANT
  u32 <<= -5; // NON_COMPLIANT
  u32 >>= -1; // NON_COMPLIANT
  u32 >>= -3; // NON_COMPLIANT
}

void test_exception_signed_constant_left_operand_exception() {
  // Exception cases for signed constant expressions
  1 << 30; // COMPLIANT
  2 << 29; // COMPLIANT
  4 << 28; // COMPLIANT
  8 << 27; // COMPLIANT

  1 << 31; // NON_COMPLIANT
  2 << 30; // NON_COMPLIANT
  4 << 29; // NON_COMPLIANT
  8 << 28; // NON_COMPLIANT

  1LL << 31;                    // COMPLIANT - 64 bit type
  1LL << 62;                    // COMPLIANT - 64 bit type
  1LL << 63;                    // NON_COMPLIANT - 64 bit type
  0x1000'0000'0000'0000LL << 2; // COMPLIANT
  0x2000'0000'0000'0000LL << 1; // COMPLIANT

  0x4000'0000'0000'0000LL << 1; // NON_COMPLIANT

  0x40000000 << 1; // NON_COMPLIANT
}

void test_exception_non_constant_signed_operand() {
  std::int32_t s32 = 1;

  s32 << 2; // NON_COMPLIANT
}

void test_right_shift_signed_operands() {
  std::uint32_t u32 = 0x80000000U;
  std::int32_t s32 = -1;

  u32 >> 1U; // COMPLIANT
  s32 >> 1U; // NON_COMPLIANT
}

class TestStream {
public:
  TestStream &operator<<(std::int32_t value);
  TestStream &operator>>(std::int32_t &value);
};

void test_overloaded_shift_operators() {
  TestStream stream;
  std::int32_t s32 = 1;

  // User provided operators, not the built-in shift operators
  stream << 1;   // COMPLIANT
  stream << s32; // COMPLIANT
  stream >> s32; // COMPLIANT
}

template <typename T>
void test_overloaded_shift_operators_in_template(TestStream &stream,
                                                 const T &value) {
  // The left operand of the second `<<` is the `TestStream &` returned by the
  // first one, and the right operand is dependent, so the operation is
  // unresolved in the uninstantiated template body
  stream << 1 << value; // COMPLIANT
}

template <typename T> void test_dependent_shift_operands(T value) {
  // Dependent operands are unresolved in the uninstantiated template body, but
  // reported through the instantiation below
  value << 2; // NON_COMPLIANT
}

void test_template_instantiations() {
  TestStream stream;
  test_overloaded_shift_operators_in_template(stream, 1);
  test_dependent_shift_operands<std::int32_t>(1);
}
enum UnscopedEnumNoFixedUnderlyingType { EnumeratorA = 1, EnumeratorB = 2 };

enum UnscopedEnumUnsignedUnderlyingType : unsigned int { EnumeratorC = 1 };

enum UnscopedEnumSignedUnderlyingType : int { EnumeratorD = 1 };

void test_enum_operands() {
  UnscopedEnumNoFixedUnderlyingType e1 = EnumeratorA;
  UnscopedEnumUnsignedUnderlyingType e2 = EnumeratorC;
  UnscopedEnumSignedUnderlyingType e3 = EnumeratorD;

  // Without a fixed underlying type the enum has no MISRA numeric type, so the
  // operands are not analysed by this rule
  e1 &e1; // COMPLIANT

  e2 &e2; // COMPLIANT

  e3 &e3; // NON_COMPLIANT
}

void test_character_type_operands() {
  char32_t c32 = 1;

  // `char32_t` is of character type, not of numeric type, and is always
  // unsigned
  c32 &c32;  // COMPLIANT
  c32 << 1U; // COMPLIANT
  ~c32;      // COMPLIANT
}
