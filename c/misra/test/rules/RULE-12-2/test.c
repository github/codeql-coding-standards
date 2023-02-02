#include <stdint.h>

const short int s1 = 15;
const short int s2 = -1;
const short int s3 = 16;
const int s4 = -1;
const int s5 = 32;
const int s6 = 21;

const long int s7 = 64;
const long int s8 = 63;

void f1() {
  int a;
  short b;
  long c;
  char d;

  a = a << s1; // COMPLIANT
  a = a << s2; // NON_COMPLIANT
  a = a << s3; // COMPLIANT
  a = a << s4; // NON_COMPLIANT
  a = a << s5; // NON_COMPLIANT
  a = a << s6; // COMPLIANT
  a = a << s7; // NON_COMPLIANT
  a = a << s8; // NON_COMPLIANT

  b = b << s1; // COMPLIANT
  b = b << s2; // NON_COMPLIANT
  b = b << s3; // NON_COMPLIANT
  b = b << s4; // NON_COMPLIANT
  b = b << s5; // NON_COMPLIANT
  b = b << s6; // NON_COMPLIANT
  b = b << s7; // NON_COMPLIANT
  b = b << s8; // NON_COMPLIANT

  c = c << s1; // COMPLIANT
  c = c << s2; // NON_COMPLIANT
  c = c << s3; // COMPLIANT
  c = c << s4; // NON_COMPLIANT
  c = c << s5; // COMPLIANT
  c = c << s6; // COMPLIANT
  c = c << s7; // NON_COMPLIANT
  c = c << s8; // COMPLIANT
 
  d = d << -1; // NON_COMPLIANT
  d = d << 8;  // NON_COMPLIANT
  d = d << 7;  // COMPLIANT
  d = d << 0;  // COMPLIANT
}

void f2() {
  int a;
  short b;
  char c;
  long long d;

  int aa = 10;
  aa++;

  a = a << aa; // COMPLIANT
  b = b << aa; // COMPLIANT
  c = c << aa; // NON_COMPLIANT
  d = d << aa; // COMPLIANT
}

void f3() {
  uint8_t u8;
  uint16_t u16;
  u8 = u8 << 7;            // COMPLIANT
  u8 = u8 << 8;            // NON_COMPLIANT
  u16 = (uint16_t)u8 << 9; // COMPLIANT
// 0u is essentially unsigned char
  0u << 10;          // NON_COMPLIANT[FALSE_NEGATIVE]
  (uint16_t)0 << 20; // NON_COMPLIANT
  0UL << 10;         // COMPLIANT
  0UL >> 100;        // NON_COMPLIANT
}