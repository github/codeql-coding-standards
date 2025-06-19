#include <stdlib.h>

int f1();
void (*g1)(void);
int (*g2)(int);
void *g3 = NULL;

struct S {
  int (*fp)(void);
  int x;
};

typedef int (*handler_t)(void);
handler_t get_handler(void);

void f2(void) {
  if (f1 == 0) // NON-COMPLIANT
    return;

  if (f1 > 0) // NON-COMPLIANT
    return;

  if (f1() == 0) // COMPLIANT
    return;

  if (f1() > 0) // COMPLIANT
    return;

  if (g1 == 0) // NON-COMPLIANT
    return;

  if (g2 == NULL) // NON-COMPLIANT
    return;

  if (g1 != 0x0) // NON-COMPLIANT
    return;

  if (f1) // NON-COMPLIANT - implicit comparison
    return;

  if (g1) // NON-COMPLIANT - implicit comparison
    return;
}

void f3(void *p1) {
  if (g1 == p1) // COMPLIANT - comparing to variable
    return;

  if (g2 == g3) // COMPLIANT - comparing to variable
    return;
}

void f4(void) {
  int (*l1)(void) = 0;

  if (f1 == f1) // COMPLIANT - comparing to constant value of same type
    return;

  if (f1 == l1) // COMPLIANT - comparing to constant value of same type
    return;

  if (f1 == (int (*)(void))0) // COMPLIANT - explicit cast
    return;

  if (f1 == (int (*)(void))0) // COMPLIANT - explicit cast
    return;

  if (f1 == (int (*)(int))0) // NON-COMPLIANT - explicit cast to wrong type
    return;

  if (f1 == (int)0) // NON-COMPLIANT - cast to non-function pointer type
    return;

  if (f1 ==
      (int)(int (*)(void))
          NULL) // NON-COMPLIANT - compliant cast subsumed by non-compliant cast
    return;
}

typedef void (*func_t)(void);
void f5(void) {
  func_t l1 = g1;
  l1 == 0;         // NON-COMPLIANT
  l1 == NULL;      // NON-COMPLIANT
  l1 == (func_t)0; // COMPLIANT - cast to function pointer type
}

void f6(void) {
  g1 + 0;     // COMPLIANT - not a comparison
  g1 == g2;   // COMPLIANT - not comparing to constant
  g1 ? 1 : 0; // NON-COMPLIANT - implicit comparison
}

void f7(void) {
  struct S s;
  if (s.fp == NULL) // NON-COMPLIANT
    f1();

  if (s.fp() == NULL) // COMPLIANT
    return;

  if (get_handler == 0) // NON-COMPLIANT - missing parentheses
    return;

  if (get_handler() == 0) // NON-COMPLIANT
    return;

  if (get_handler() == (handler_t)0) // COMPLIANT
    return;

  if (get_handler()() == 0) // COMPLIANT
    return;
}

void f8(void) {
  // Test instances of where the function pointer check is used to guard calls
  // to that function.

  // Technically, this function may perhaps be set to NULL by the linker. But
  // it is not a variable that should need to be null-checked at runtime.
  if (f1 != 0) // NON-COMPLIANT
  {
    f1();
  }

  // Check guards a call, so it is compliant.
  if (g1 != 0) // COMPLIANT
  {
    g1();
  }

  // Incorrect check, not compliant.
  if (g1 != 0) // NON-COMPLIANT
  {
    f1();
  }

  // Incorrect check, not compliant.
  if (g1 == 0) // NON-COMPLIANT
  {
    g1();
  }

  if (g1) // COMPLIANT
  {
    g1();
  }

  if (!g1) // NON-COMPLIANT
  {
    g1();
  }
}