#include <stddef.h>

struct s1 {
  void *v1;
  void *v2;
};

struct s1 g_v1 = {0}; // COMPLIANT

void *f1(void *p1, int p2) {
  if (p1 == (void *)0) { // COMPLIANT
  }
  if (p1 == NULL) { // COMPLIANT
  }
  if (p1 == 0) { // NON_COMPLIANT
  }
  p1 = 0;         // NON_COMPLIANT
  p1 = (void *)0; // COMPLIANT
  p1 = NULL;      // COMPLIANT
  if (p2 == 0) {  // COMPLIANT
    return NULL;
  }
  p2 ? p1 : 0;     // NON_COMPLIANT
  p2 ? 0 : p1;     // NON_COMPLIANT
  p2 ? (void*) 0 : p1;     // COMPLIANT
  p2 ? p1 : (void*) 0;     // COMPLIANT
  p2 ? p2 : 0;     // COMPLIANT - p2 is not a pointer type
  p2 ? 0 : p2;     // COMPLIANT - p2 is not a pointer type
  return 0;                             // COMPLIANT
}