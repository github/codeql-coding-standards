#include <cstdint>

void test_variable_width_type_variables() {
  char c;           // COMPLIANT
  unsigned char uc; // NON_COMPLIANT
  signed char sc;   // NON_COMPLIANT

  int i;           // NON_COMPLIANT
  unsigned int ui; // NON_COMPLIANT
  unsigned u;      // NON_COMPLIANT
  signed int si;   // NON_COMPLIANT
  signed s;        // NON_COMPLIANT

  short sh;           // NON_COMPLIANT
  unsigned short ush; // NON_COMPLIANT
  signed short ssh;   // NON_COMPLIANT

  long l;           // NON_COMPLIANT
  unsigned long ul; // NON_COMPLIANT
  signed long sl;   // NON_COMPLIANT

  std::int8_t i8;   // COMPLIANT
  std::int16_t i16; // COMPLIANT
  std::int32_t i32; // COMPLIANT
  std::int64_t i64; // COMPLIANT

  std::uint8_t u8;   // COMPLIANT
  std::uint16_t u16; // COMPLIANT
  std::uint32_t u32; // COMPLIANT
  std::uint64_t u64; // COMPLIANT
}

int main(int argc, char *argv[]) { // COMPLIANT
  // main as an exception
}

void test_variable_width_type_qualified_variables() {
  const char c1 = 0;           // COMPLIANT
  const unsigned char uc1 = 0; // NON_COMPLIANT
  const signed char sc1 = 0;   // NON_COMPLIANt

  const int i1 = 0;           // NON_COMPLIANT
  const unsigned int ui1 = 0; // NON_COMPLIANT
  const unsigned u1 = 0;      // NON_COMPLIANT
  const signed int si1 = 0;   // NON_COMPLIANT
  const signed s1 = 0;        // NON_COMPLIANT

  const short sh1 = 0;           // NON_COMPLIANT
  const unsigned short ush1 = 0; // NON_COMPLIANT
  const signed short ssh1 = 0;   // NON_COMPLIANT

  const long l1 = 0;           // NON_COMPLIANT
  const unsigned long ul1 = 0; // NON_COMPLIANT
  const signed long sl1 = 0;   // NON_COMPLIANT

  volatile char c2;           // COMPLIANT
  volatile unsigned char uc2; // NON_COMPLIANT
  volatile signed char sc2;   // NON_COMPLIANt

  volatile int i2;           // NON_COMPLIANT
  volatile unsigned int ui2; // NON_COMPLIANT
  volatile unsigned u2;      // NON_COMPLIANT
  volatile signed int si2;   // NON_COMPLIANT
  volatile signed s2;        // NON_COMPLIANT

  volatile short sh2;           // NON_COMPLIANT
  volatile unsigned short ush2; // NON_COMPLIANT
  volatile signed short ssh2;   // NON_COMPLIANT

  volatile long l2;           // NON_COMPLIANT
  volatile unsigned long ul2; // NON_COMPLIANT
  volatile signed long sl2;   // NON_COMPLIANT
}

struct test_fix_fp_614 {
  test_fix_fp_614 operator++(int); // COMPLIANT
  test_fix_fp_614 operator--(int); // COMPLIANT
};

// COMPLIANT - instantiated with Fixed Width Types.
template <typename MyType> constexpr void test_fix_fp_540(MyType value) {
  value++;
}

void call_test_fix_fp_540() {
  test_fix_fp_540<std::uint8_t>(19);
  test_fix_fp_540<std::int16_t>(20);
}

char test_char_return() { // COMPLIANT
  return 'a';
}
unsigned char test_unsigned_char_return() { // NON_COMPLIANT
  return 'b';
}
signed char test_signed_char_return() { // NON_COMPLIANT
  return 'c';
}
int test_int_return() { // NON_COMPLIANT
  return 42;
}
unsigned int test_unsigned_int_return() { // NON_COMPLIANT
  return 43;
}
unsigned test_unsigned_return() { // NON_COMPLIANT
  return 44;
}
signed int test_signed_int_return() { // NON_COMPLIANT
  return 45;
}
signed test_signed_return() { // NON_COMPLIANT
  return 46;
}
short test_short_return() { // NON_COMPLIANT
  return 47;
}
unsigned short test_unsigned_short_return() { // NON_COMPLIANT
  return 48;
}
signed short test_signed_short_return() { // NON_COMPLIANT
  return 49;
}
long test_long_return() { // NON_COMPLIANT
  return 50;
}
unsigned long test_unsigned_long_return() { // NON_COMPLIANT
  return 51;
}
signed long test_signed_long_return() { // NON_COMPLIANT
  return 52;
}
std::int8_t test_int8_t_return() { // COMPLIANT
  return 53;
}
std::int16_t test_int16_t_return() { // COMPLIANT
  return 54;
}
std::int32_t test_int32_t_return() { // COMPLIANT
  return 55;
}
std::int64_t test_int64_t_return() { // COMPLIANT
  return 56;
}
std::uint8_t test_uint8_t_return() { // COMPLIANT
  return 57;
}
std::uint16_t test_uint16_t_return() { // COMPLIANT
  return 58;
}
std::uint32_t test_uint32_t_return() { // COMPLIANT
  return 59;
}
std::uint64_t test_uint64_t_return() { // COMPLIANT
  return 60;
}
