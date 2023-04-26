#include <limits.h>
#include <stdint.h>
void f1() {
  uint8_t ui8;
  int b = 4;

  ui8 << 7;             // COMPLIANT
  ui8 >> 8;             // NON_COMPLIANT
  ui8 >> -1;            // NON_COMPLIANT
  ui8 >> 4 + b;         // NON_COMPLIANT
  ui8 << b + b;         // NON_COMPLIANT
  (uint16_t) ui8 << 8;  // COMPLIANT
  (uint16_t) ui8 << 16; // NON_COMPLIANT

  // 0u essential type is essentially unsigned char
  0u << 8;           // NON_COMPLIANT
  (uint16_t)0u << 8; // COMPLIANT

  unsigned long ul;
  ul << 8;  // COMPLIANT
  ul << 64; // NON_COMPLIANT

  // 1UL essential type is essentially unsigned char
  1UL << 7;  // COMPLIANT
  1UL << 8;  // NON_COMPLIANT
  1UL << 64; // NON_COMPLIANT

  // ULONG_MAX essential type is essentially unsigned long
  ULONG_MAX << 8;  // COMPLIANT
  ULONG_MAX << 64; // NON_COMPLIANT
}
