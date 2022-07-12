#include <cstdint>

void f1() {
  unsigned char a1 = 'c'; // NON_COMPLIANT
  unsigned char a2 = 10;
  signed char a3 = 'c'; // NON_COMPLIANT
  signed char a4 = 10;

  std::int8_t a5 = 'c'; // NON_COMPLIANT
  std::int8_t a6 = 10;

  std::uint8_t a7 = 'c'; // NON_COMPLIANT
  std::uint8_t a8 = 10;

  char a9 = 'c';
}