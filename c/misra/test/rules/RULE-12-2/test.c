#include <stdint.h>

void f1() {
  uint8_t ui8;
  int b = 4;

  ui8 << 7;            // COMPLIANT
  ui8 >> 8;            // NON_COMPLIANT
  ui8 << 3 + 3;        // COMPLIANT
  ui8 >> 4 + b;        // NON_COMPLIANT
  ui8 << b + b;        // NON_COMPLIANT
  (uint16_t) ui8 << 9; // COMPLIANT

  // 0u essential type is essentially unsigned char
  0u << 8;           // NON_COMPLIANT
  (uint16_t)0u << 8; // COMPLIANT

  unsigned long ul;
  ul << 10; // COMPLIANT
  ul << 64; // NON_COMPLIANT

  // 1UL essential type is essentially unsigned long
  1UL << 10; // COMPLIANT[FALSE_POSITIVE]
  1UL << 64; // NON_COMPLIANT
}
