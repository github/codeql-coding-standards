#include <cinttypes>

void test_unsigned() {
  unsigned int a = 0;
  unsigned short b = 0;

  a &a;    // COMPLIANT
  a | a;   // COMPLIANT
  a ^ a;   // COMPLIANT
  a << 1;  // COMPLIANT
  a >> 1;  // COMPLIANT
  a &= a;  // COMPLIANT
  a |= a;  // COMPLIANT
  a ^= a;  // COMPLIANT
  a <<= a; // COMPLIANT
  a >>= a; // COMPLIANT

  a &b;    // NON_COMPLIANT
  a | b;   // NON_COMPLIANT
  a ^ b;   // NON_COMPLIANT
  a << b;  // NON_COMPLIANT
  a >> b;  // NON_COMPLIANT
  a &= b;  // NON_COMPLIANT
  a |= b;  // NON_COMPLIANT
  a ^= b;  // NON_COMPLIANT
  a <<= b; // NON_COMPLIANT
  a >>= b; // NON_COMPLIANT
}

void test_inttypes() {
  uint8_t a = 0;
  uint16_t b = 0;

  a &a;    // COMPLIANT
  a | a;   // COMPLIANT
  a ^ a;   // COMPLIANT
  a << 1;  // COMPLIANT
  a >> 1;  // COMPLIANT
  a &= a;  // COMPLIANT
  a |= a;  // COMPLIANT
  a ^= a;  // COMPLIANT
  a <<= a; // COMPLIANT
  a >>= a; // COMPLIANT

  a &b;    // NON_COMPLIANT
  a | b;   // NON_COMPLIANT
  a ^ b;   // NON_COMPLIANT
  a << b;  // NON_COMPLIANT
  a >> b;  // NON_COMPLIANT
  a &= b;  // NON_COMPLIANT
  a |= b;  // NON_COMPLIANT
  a ^= b;  // NON_COMPLIANT
  a <<= b; // NON_COMPLIANT
  a >>= b; // NON_COMPLIANT
}

#include <sstream>
template <typename S, typename T> static void test463_1(S &val, T &shift) {
  val << shift; // COMPLIANT
}
void test463_1_instantiations() {
  int val = 1;
  int shift1 = 1;
  test463_1(val, shift1);
}
template <typename S, typename T> static void test463_2(S &val, T &shift) {
  val << shift; // NON_COMPLIANT
}
void test463_2_instantiations() {
  int val = 1;
  char shift2 = 2;
  test463_2(val, shift2);
}
