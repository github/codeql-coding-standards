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