#include <stddef.h>

void f1(void) {
  void *v1 = (void *)0;  // COMPLIANT
  v1 = NULL;             // COMPLIANT
  int *v2 = (int *)v1;   // NON_COMPLIANT
  v2 = NULL;             // COMPLIANT
  void *v3 = (void *)v1; // COMPLIANT
  v3 = (void *)v2;       // COMPLIANT
  const void *v4 = 0;
  (int *)v4;        // NON_COMPLIANT - const in type is irrelevant
  (const void *)v1; // COMPLIANT - casting is from void to void, const addition
                    // should be irrelevant
}