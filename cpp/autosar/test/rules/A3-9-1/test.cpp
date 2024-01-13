#include <cstdint>

void test_variable_width_type_variables() {
  char c;           // NON_COMPLIANT
  unsigned char uc; // NON_COMPLIANT
  signed char sc;   // NON_COMPLIANt

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
  const char c1 = 0;           // NON_COMPLIANT
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
  
  volatile char c2;           // NON_COMPLIANT
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