#include <stdbool.h>

void f1(void) {
  int *v1;
  bool v2 = (bool)v1;         // NON_COMPLIANT
  bool v3 = 0;                // COMPLIANT
  float v4 = (float)(bool)v1; // NON_COMPLIANT
  v1 = (int *)v2;             // NON_COMPLIANT
  v4 = (float)v3;             // COMPLIANT
  void *v5 = 0;
  const void *v6 = 0;
  // void pointers (regardless of specifier) are not pointers to object, so all
  // these examples are compliant according to this rule
  (bool)v5;         // COMPLIANT
  (bool)v6;         // COMPLIANT
  (void *)v2;       // COMPLIANT
  (const void *)v2; // COMPLIANT
}