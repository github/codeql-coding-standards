#include <stdbool.h>

void testAssignment() {
  _Bool b = true;             // COMPLIANT
  enum E1 { A, B, C } e1 = A; // COMPLIANT
  signed int s = 100;         // COMPLIANT
  unsigned int u = 100;       // COMPLIANT - by exception 1
  float f = 10.0f;            // COMPLIANT

  b = false; // COMPLIANT
  b = e1;    // NON_COMPLIANT
  b = s;     // NON_COMPLIANT
  b = u;     // NON_COMPLIANT
  b = f;     // NON_COMPLIANT

  e1 = b;  // NON_COMPLIANT
  e1 = e1; // COMPLIANT
  e1 = s;  // NON_COMPLIANT
  e1 = u;  // NON_COMPLIANT
  e1 = f;  // NON_COMPLIANT

  s = b;  // NON_COMPLIANT
  s = e1; // NON_COMPLIANT
  s = s;  // COMPLIANT
  s = u;  // NON_COMPLIANT
  s = f;  // NON_COMPLIANT

  u = b;  // NON_COMPLIANT
  u = e1; // NON_COMPLIANT
  u = s;  // NON_COMPLIANT
  u = u;  // COMPLIANT
  u = f;  // NON_COMPLIANT

  f = b;  // NON_COMPLIANT
  f = e1; // NON_COMPLIANT
  f = s;  // NON_COMPLIANT
  f = u;  // NON_COMPLIANT
  f = f;  // COMPLIANT
}

void testInitializers() {
  _Bool b = true;             // COMPLIANT
  enum E1 { A, B, C } e1 = A; // COMPLIANT
  signed int s = 100;         // COMPLIANT
  unsigned int u = 100;       // COMPLIANT - by exception 1
  float f = 10.0f;            // COMPLIANT

  _Bool bb = b;  // COMPLIANT
  _Bool be = e1; // NON_COMPLIANT
  _Bool bs = s;  // NON_COMPLIANT
  _Bool bu = u;  // NON_COMPLIANT
  _Bool bf = f;  // NON_COMPLIANT

  enum E1 e1b = b;  // NON_COMPLIANT
  enum E1 e1e = e1; // COMPLIANT
  enum E1 e1s = s;  // NON_COMPLIANT
  enum E1 e1u = u;  // NON_COMPLIANT
  enum E1 e1f = f;  // NON_COMPLIANT

  signed int sb = b;  // NON_COMPLIANT
  signed int se = e1; // NON_COMPLIANT
  signed int ss = s;  // COMPLIANT
  signed int su = u;  // NON_COMPLIANT
  signed int sf = f;  // NON_COMPLIANT

  unsigned int ub = b;  // NON_COMPLIANT
  unsigned int ue = e1; // NON_COMPLIANT
  unsigned int us = s;  // NON_COMPLIANT
  unsigned int uu = u;  // COMPLIANT
  unsigned int uf = f;  // NON_COMPLIANT

  float fb = b;  // NON_COMPLIANT
  float fe = e1; // NON_COMPLIANT
  float fs = s;  // NON_COMPLIANT
  float fu = u;  // NON_COMPLIANT
  float ff = f;  // COMPLIANT

  _Bool ba[5] = {
      b,  // COMPLIANT
      e1, // NON_COMPLIANT
      s,  // NON_COMPLIANT
      u,  // NON_COMPLIANT
      f   // NON_COMPLIANT
  };
  enum E1 ea[5] = {
      b,  // NON_COMPLIANT
      e1, // COMPLIANT
      s,  // NON_COMPLIANT
      u,  // NON_COMPLIANT
      f   // NON_COMPLIANT
  };
  signed int sa[5] = {
      b,  // NON_COMPLIANT
      e1, // NON_COMPLIANT
      s,  // COMPLIANT
      u,  // NON_COMPLIANT
      f   // NON_COMPLIANT
  };
  unsigned int ua[5] = {
      b,  // NON_COMPLIANT
      e1, // NON_COMPLIANT
      s,  // NON_COMPLIANT
      u,  // COMPLIANT
      f   // NON_COMPLIANT
  };
  float fa[5] = {
      b,  // NON_COMPLIANT
      e1, // NON_COMPLIANT
      s,  // NON_COMPLIANT
      u,  // NON_COMPLIANT
      f   // COMPLIANT
  };
}

void testException1() {
  unsigned int u = 100; // COMPLIANT - by exception 1
  u = 100;              // COMPLIANT - by exception 1
  u = -1; // NON_COMPLIANT - smaller that uint, so exception doesn't apply
  u = 4294967296; // NON_COMPLIANT - cannot be stored in an int, so exception
                  // doesn't apply
}

void testSwitchCase() {
  _Bool b = true;             // COMPLIANT
  enum E1 { A, B, C } e1 = A; // COMPLIANT
  signed int s = 100;         // COMPLIANT
  unsigned int u = 100;       // COMPLIANT - by exception 1
  float f = 10.0f;            // COMPLIANT
  switch (b) {
  case true:                // COMPLIANT
  case A:                   // NON_COMPLIANT
  case 100:                 // NON_COMPLIANT
  case ((unsigned int)200): // NON_COMPLIANT
    break;                  // case 1.0f:                // NON_COMPILABLE
  }

  switch (e1) {
  case true:                // NON_COMPLIANT
  case A:                   // COMPLIANT
  case 100:                 // NON_COMPLIANT
  case ((unsigned int)200): // NON_COMPLIANT
    break;                  // case 1.0f:                // NON_COMPILABLE
  }

  switch (s) {
  case true:                // NON_COMPLIANT
  case A:                   // NON_COMPLIANT
  case 100:                 // COMPLIANT
  case ((unsigned int)200): // NON_COMPLIANT
    break;                  // case 1.0f:                // NON_COMPILABLE
  }

  switch (u) {
  case true:                // NON_COMPLIANT
  case A:                   // NON_COMPLIANT
  case 100:                 // COMPLIANT - by exception 1
  case ((unsigned int)200): // COMPLIANT - by exception 1
    break;                  // case 1.0f:                // NON_COMPILABLE
  }
}

enum EG { EGA, EGB, EGC };

void func(_Bool b, enum EG eg, signed int i, unsigned int u, float f);

void testFunctionCall() {
  _Bool b = true;       // COMPLIANT
  enum EG e1 = EGA;     // COMPLIANT
  signed int s = 100;   // COMPLIANT
  unsigned int u = 100; // COMPLIANT - by exception 1
  float f = 10.0f;      // COMPLIANT

  func(b, // COMPLIANT
       b, // NON_COMPLIANT
       b, // NON_COMPLIANT
       b, // NON_COMPLIANT
       b  // NON_COMPLIANT
  );

  func(e1, // NON_COMPLIANT
       e1, // COMPLIANT
       e1, // NON_COMPLIANT
       e1, // NON_COMPLIANT
       e1  // NON_COMPLIANT
  );

  func(s, // NON_COMPLIANT
       s, // NON_COMPLIANT
       s, // COMPLIANT
       s, // NON_COMPLIANT
       s  // NON_COMPLIANT
  );

  func(u, // NON_COMPLIANT
       u, // NON_COMPLIANT
       u, // NON_COMPLIANT
       u, // COMPLIANT
       u  // NON_COMPLIANT
  );

  func(f, // NON_COMPLIANT
       f, // NON_COMPLIANT
       f, // NON_COMPLIANT
       f, // NON_COMPLIANT
       f  // COMPLIANT
  );
}

_Bool testBoolFunctionReturn(int x) {
  _Bool b = true;       // COMPLIANT
  enum EG e1 = EGA;     // COMPLIANT
  signed int s = 100;   // COMPLIANT
  unsigned int u = 100; // COMPLIANT - by exception 1
  float f = 10.0f;      // COMPLIANT

  switch (x) {
  case 0:
    return b; // COMPLIANT
  case 1:
    return e1; // NON_COMPLIANT
  case 2:
    return s; // NON_COMPLIANT
  case 3:
    return u; // NON_COMPLIANT
  default:
    return f; // NON_COMPLIANT
  }
}

enum EG testEnumFunctionReturn(int x) {
  _Bool b = true;       // COMPLIANT
  enum EG e1 = EGA;     // COMPLIANT
  signed int s = 100;   // COMPLIANT
  unsigned int u = 100; // COMPLIANT - by exception 1
  float f = 10.0f;      // COMPLIANT

  switch (x) {
  case 0:
    return b; // NON_COMPLIANT
  case 1:
    return e1; // COMPLIANT
  case 2:
    return s; // NON_COMPLIANT
  case 3:
    return u; // NON_COMPLIANT
  default:
    return f; // NON_COMPLIANT
  }
}

signed int testSignedIntFunctionReturn(int x) {
  _Bool b = true;       // COMPLIANT
  enum EG e1 = EGA;     // COMPLIANT
  signed int s = 100;   // COMPLIANT
  unsigned int u = 100; // COMPLIANT - by exception 1
  float f = 10.0f;      // COMPLIANT

  switch (x) {
  case 0:
    return b; // NON_COMPLIANT
  case 1:
    return e1; // NON_COMPLIANT
  case 2:
    return s; // COMPLIANT
  case 3:
    return u; // NON_COMPLIANT
  default:
    return f; // NON_COMPLIANT
  }
}

unsigned int testUnsignedIntFunctionReturn(int x) {
  _Bool b = true;       // COMPLIANT
  enum EG e1 = EGA;     // COMPLIANT
  signed int s = 100;   // COMPLIANT
  unsigned int u = 100; // COMPLIANT - by exception 1
  float f = 10.0f;      // COMPLIANT

  switch (x) {
  case 0:
    return b; // NON_COMPLIANT
  case 1:
    return e1; // NON_COMPLIANT
  case 2:
    return s; // NON_COMPLIANT
  case 3:
    return u; // COMPLIANT
  default:
    return f; // NON_COMPLIANT
  }
}

float testFloatFunctionReturn(int x) {
  _Bool b = true;       // COMPLIANT
  enum EG e1 = EGA;     // COMPLIANT
  signed int s = 100;   // COMPLIANT
  unsigned int u = 100; // COMPLIANT - by exception 1
  float f = 10.0f;      // COMPLIANT

  switch (x) {
  case 0:
    return b; // NON_COMPLIANT
  case 1:
    return e1; // NON_COMPLIANT
  case 2:
    return s; // NON_COMPLIANT
  case 3:
    return u; // NON_COMPLIANT
  default:
    return f; // COMPLIANT
  }
}

struct S1 {
  _Bool b;
  enum EG e1;
  signed int s;
  unsigned int u;
  float f;
};

void testStructAssignment() {
  _Bool b = true;       // COMPLIANT
  enum EG e1 = EGA;     // COMPLIANT
  signed int s = 100;   // COMPLIANT
  unsigned int u = 100; // COMPLIANT - by exception 1
  float f = 10.0f;      // COMPLIANT

  struct S1 s1;

  s1.b = b;  // COMPLIANT
  s1.b = e1; // NON_COMPLIANT
  s1.b = s;  // NON_COMPLIANT
  s1.b = u;  // NON_COMPLIANT
  s1.b = f;  // NON_COMPLIANT

  s1.e1 = b;  // NON_COMPLIANT
  s1.e1 = e1; // COMPLIANT
  s1.e1 = s;  // NON_COMPLIANT
  s1.e1 = u;  // NON_COMPLIANT
  s1.e1 = f;  // NON_COMPLIANT

  s1.s = b;  // NON_COMPLIANT
  s1.s = e1; // NON_COMPLIANT
  s1.s = s;  // COMPLIANT
  s1.s = u;  // NON_COMPLIANT
  s1.s = f;  // NON_COMPLIANT

  s1.u = b;  // NON_COMPLIANT
  s1.u = e1; // NON_COMPLIANT
  s1.u = s;  // NON_COMPLIANT
  s1.u = u;  // COMPLIANT
  s1.u = f;  // NON_COMPLIANT

  s1.f = b;  // NON_COMPLIANT
  s1.f = e1; // NON_COMPLIANT
  s1.f = s;  // NON_COMPLIANT
  s1.f = u;  // NON_COMPLIANT
  s1.f = f;  // COMPLIANT
}