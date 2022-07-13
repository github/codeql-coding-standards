#include <stdbool.h>

void f1(void) {
  int *v1;
  bool v2 = (bool)v1;         // NON_COMPLIANT
  bool v3 = 0;                // COMPLIANT
  float v4 = (float)(bool)v1; // NON_COMPLIANT
  v1 = (int *)v2;             // NON_COMPLIANT
  v4 = (float)v3;             // COMPLIANT
}