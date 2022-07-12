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
  }                                     // COMPLIANT
  (p1) ? (p1 = NULL) : (p1 = NULL);     // COMPLIANT
  (p2 > 0) ? (p1 = NULL) : (p1 = NULL); // COMPLIANT
  (p2 > 0) ? (p1 = 0) : (p1 = NULL);    // NON_COMPLIANT
  return 0;                             // COMPLIANT
}