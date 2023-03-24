#include <stdbool.h>

void testIncompatibleCasts() {
  enum E1 { A, B };

  _Bool b = true;

  (_Bool) b;       // COMPLIANT
  (char)b;         // NON_COMPLIANT
  (enum E1) b;     // NON_COMPLIANT
  (signed int)b;   // NON_COMPLIANT
  (unsigned int)b; // NON_COMPLIANT
  (float)b;        // NON_COMPLIANT

  char c = 100;
  (_Bool) c;       // NON_COMPLIANT
  (char)c;         // COMPLIANT
  (enum E1) c;     // NON_COMPLIANT
  (signed int)c;   // COMPLIANT
  (unsigned int)c; // COMPLIANT
  (float)c;        // NON_COMPLIANT

  enum E2 { C, D } e = C;
  (_Bool) e;       // NON_COMPLIANT
  (char)e;         // COMPLIANT
  (enum E1) e;     // NON_COMPLIANT
  (enum E2) e;     // COMPLIANT
  (signed int)e;   // COMPLIANT
  (unsigned int)e; // COMPLIANT
  (float)e;        // COMPLIANT

  signed int i = 100;
  (_Bool) i;       // NON_COMPLIANT
  (char)i;         // COMPLIANT
  (enum E1) i;     // NON_COMPLIANT
  (signed int)i;   // COMPLIANT
  (unsigned int)i; // COMPLIANT
  (float)i;        // COMPLIANT

  unsigned int u = 100;
  (_Bool) u;       // NON_COMPLIANT
  (char)u;         // COMPLIANT
  (enum E1) u;     // NON_COMPLIANT
  (signed int)u;   // COMPLIANT
  (unsigned int)u; // COMPLIANT
  (float)u;        // COMPLIANT

  float f = 100.0;
  (_Bool) f;       // NON_COMPLIANT
  (char)f;         // NON_COMPLIANT
  (enum E1) f;     // NON_COMPLIANT
  (signed int)f;   // COMPLIANT
  (unsigned int)f; // COMPLIANT
  (float)f;        // COMPLIANT
}

void testImplicit() {
  // Implicit conversions are not checked by this rule.
  char c = true; // Not covered by rule
  _Bool b = 100; // Not covered by rule
  unsigned int u = 100;
  _Bool b2 = u; // Not covered by rule
}

void testIntegerConstantBool() {
  (_Bool)0; // COMPLIANT
  (_Bool)1; // COMPLIANT
  (_Bool)2; // NON_COMPLIANT
  enum MyBool { f, t };
  (enum MyBool)0; // COMPLIANT
  (enum MyBool)1; // COMPLIANT
  (enum MyBool)2; // NON_COMPLIANT
  typedef int boolean;
  (boolean)0; // COMPLIANT
  (boolean)1; // COMPLIANT
  (boolean)2; // NON_COMPLIANT
}