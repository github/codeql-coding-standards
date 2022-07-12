void test() {
  int a = 0;

  a + 1;  // COMPLIANT
  a - 1;  // COMPLIANT
  a / 1;  // COMPLIANT
  a * 1;  // COMPLIANT
  a += 1; // COMPLIANT
  a -= 1; // COMPLIANT
  a /= 1; // COMPLIANT
  a *= 1; // COMPLIANT
  a % 2;  // COMPLIANT

  ~a;      // NON_COMPLIANT
  a << 1;  // NON_COMPLIANT
  a <<= 1; // NON_COMPLIANT
  a >> 1;  // NON_COMPLIANT
  a >>= 1; // NON_COMPLIANT
  a & 0;   // NON_COMPLIANT
  a &= 0;  // NON_COMPLIANT
  a ^ 0;   // NON_COMPLIANT
  a ^= 0;  // NON_COMPLIANT
  a | 0;   // NON_COMPLIANT
  a |= 0;  // NON_COMPLIANT

  unsigned int u = 1;

  u + 1;   // COMPLIANT
  u - 1;   // COMPLIANT
  u / 1;   // COMPLIANT
  u * 1;   // COMPLIANT
  u += 1;  // COMPLIANT
  u -= 1;  // COMPLIANT
  u /= 1;  // COMPLIANT
  u *= 1;  // COMPLIANT
  u % 2;   // COMPLIANT
  ~u;      // COMPLIANT
  u << 1;  // COMPLIANT
  u <<= 1; // COMPLIANT
  u >> 1;  // COMPLIANT
  u >>= 1; // COMPLIANT
  u &u;    // COMPLIANT
  u &= u;  // COMPLIANT
  u ^ u;   // COMPLIANT
  u ^= u;  // COMPLIANT
  u | 0;   // COMPLIANT
  u |= 0;  // COMPLIANT
}