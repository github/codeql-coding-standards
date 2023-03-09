void testOps() {
  signed int s32 = 100;
  signed long long s64 = 100;
  unsigned int u = 100;
  float f = 10.0f;
  char c = 'A';

  s32 + s32;  // COMPLIANT
  s64 + s64;  // COMPLIANT
  s32 + s64;  // COMPLIANT
  s64 + s32;  // COMPLIANT
  s64 += s32; // COMPLIANT
  s32 += s64; // COMPLIANT
  u + s32;    // NON_COMPLIANT
  s32 + u;    // NON_COMPLIANT
  s32 += u;   // NON_COMPLIANT
  f + s32;    // NON_COMPLIANT
  s32 + f;    // NON_COMPLIANT
  s32 += f;   // NON_COMPLIANT

  c + s32;  // COMPLIANT - by exception
  c += s32; // COMPLIANT - by exception
  s32 + c;  // COMPLIANT - by exception
  s32 += c; // COMPLIANT - by exception
  c - s32;  // COMPLIANT - by exception
  c -= s32; // COMPLIANT - by exception
  s32 - c;  // NON_COMPLIANT
  s32 -= c; // NON_COMPLIANT

  enum E1 { A, B, C } e1a;
  enum E2 { D, E, F } e2a;
  e1a < e1a; // COMPLIANT
  A < A;     // COMPLIANT
  e1a < e2a; // NON_COMPLIANT
  A < D;     // NON_COMPLIANT
}