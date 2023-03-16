#include <string.h>

int o[10];
void g(void) {
  memcpy(&o[1], &o[0], 2); // NON_COMPLIANT
  memcpy(&o[2], &o[0], 2); // COMPLIANT
  memcpy(&o[2], &o[1], 2); // NON_COMPLIANT
  memcpy(o + 1, o, 2);     // NON_COMPLIANT
  memcpy(o + 2, o, 2);     // COMPLIANT
  memcpy(o + 2, o + 1, 2); // NON_COMPLIANT

  // Exception 1
  int *p = &o[0];
  int *q = &o[0];

  *p = *q;                 // COMPLIANT
  memcpy(&o[0], &o[0], 2); // COMPLIANT
  memcpy(o, o, 2);         // COMPLIANT

  // Exception 2
  memmove(&o[1], &o[0], 2u * sizeof(o[0])); // COMPLIANT
}
