#include <stdbool.h>

void testRules() {
  _Bool b = true;
  enum E1 { A, B, C } e1 = A;
  signed int i = 100;
  unsigned int u = 100;
  float f = 10.0f;

  // Addition cases
  i + 'a';   // COMPLIANT
  'a' + i;   // COMPLIANT
  u + 'a';   // COMPLIANT
  'a' + u;   // COMPLIANT
  'a' + 'a'; // NON_COMPLIANT
  'a' + f;   // NON_COMPLIANT
  f + 'a';   // NON_COMPLIANT
  'a' + b;   // NON_COMPLIANT
  b + 'a';   // NON_COMPLIANT
  'a' + e1;  // NON_COMPLIANT
  e1 + 'a';  // NON_COMPLIANT

  // Subtration cases
  'a' - i;   // COMPLIANT
  'a' - u;   // COMPLIANT
  'a' - 'a'; // COMPLIANT
  'a' - f;   // NON_COMPLIANT
  i - 'a';   // NON_COMPLIANT
  u - 'a';   // NON_COMPLIANT
  f - 'a';   // NON_COMPLIANT
  b - 'a';   // NON_COMPLIANT
  'a' - b;   // NON_COMPLIANT
  e1 - 'a';  // NON_COMPLIANT
  'a' - e1;  // NON_COMPLIANT
}