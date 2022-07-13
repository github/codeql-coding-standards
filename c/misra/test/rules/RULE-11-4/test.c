#include <stddef.h>

void f1(void) {
  unsigned int v1 = (unsigned int)(void *)0; // COMPLIANT
  unsigned int v2 = (unsigned int)(int *)0;  // NON_COMPLIANT
  unsigned int v3 = (unsigned int)&v2;       // NON_COMPLIANT
  v3 = v2;                                   // COMPLIANT
  v3 = (unsigned int)&v2;                    // NON_COMPLIANT
  v3 = NULL;                                 // COMPLIANT
  unsigned int *v4 = 0;                      // NON_COMPLIANT
  unsigned int *v5 = NULL;                   // COMPLIANT
  unsigned int *v6 = (unsigned int *)v2;     // NON_COMPLIANT
}