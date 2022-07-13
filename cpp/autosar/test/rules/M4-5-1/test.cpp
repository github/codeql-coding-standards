void test() {
  bool a, b;

  a = b;     // COMPLIANT
  a &&b;     // COMPLIANT
  a || b;    // COMPLIANT
  !b;        // COMPLIANT
  b == b;    // COMPLIANT
  b != b;    // COMPLIANT
  a &b;      // COMPLIANT
  b ? b : a; // COMPLIANT

  a | b;   // NON_COMPLIANT
  a >> b;  // NON_COMPLIANT
  a << b;  // NON_COMPLIANT
  ~b;      // NON_COMPLIANT
  a / b;   // NON_COMPLIANT
  a + b;   // NON_COMPLIANT
  a - b;   // NON_COMPLIANT
  a *b;    // NON_COMPLIANT
  a % b;   // NON_COMPLIANT
  a ^ b;   // NON_COMPLIANT
  ++a;     // NON_COMPLIANT
  a++;     // NON_COMPLIANT
  a += b;  // NON_COMPLIANT
  a -= b;  // NON_COMPLIANT
  a /= b;  // NON_COMPLIANT
  a %= b;  // NON_COMPLIANT
  a *= b;  // NON_COMPLIANT
  a |= b;  // NON_COMPLIANT
  a &= b;  // NON_COMPLIANT
  a ^= b;  // NON_COMPLIANT
  a <<= b; // NON_COMPLIANT
  a >>= b; // NON_COMPLIANT
}