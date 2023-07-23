#include <stddef.h>

void f1(void) {
  unsigned int v1 = (unsigned int)(void *)0; // COMPLIANT
  unsigned int v2 = (unsigned int)(int *)0;  // COMPLIANT
  unsigned int v3 = (unsigned int)&v2;       // NON_COMPLIANT
  v3 = v2;                                   // COMPLIANT
  v3 = (unsigned int)&v2;                    // NON_COMPLIANT
  v3 = NULL;                                 // COMPLIANT
  unsigned int *v4 = 0;                      // COMPLIANT
  unsigned int *v5 = NULL;                   // COMPLIANT
  unsigned int *v6 = (unsigned int *)v2;     // NON_COMPLIANT
}

#define FOO (int *)0x200 // NON_COMPLIANT
#define FOO_WRAPPER FOO;
#define FOO_FUNCTIONAL(x) (int *)x
#define FOO_INSERT(x) x

void test_macros() {
  FOO;                      // Issue is reported at the macro
  FOO_WRAPPER;              // Issue is reported at the macro
  FOO_FUNCTIONAL(0x200);    // NON_COMPLIANT
  FOO_INSERT((int *)0x200); // NON_COMPLIANT
}