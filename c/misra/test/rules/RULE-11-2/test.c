#include <stddef.h>

void f1(void) {
  struct s1;
  struct s2;

  struct s1 *v1;
  struct s1 *v2;
  struct s2 *v3;
  void *v4;
  int *v5;

  v2 = (struct s1 *)v1; // COMPLIANT
  v3 = (struct s2 *)v1; // NON_COMPLIANT
  v4 = (void *)v1;      // NON_COMPLIANT
  v4 = (void *)v5;      // COMPLIANT
  v5 = (int *)v4;       // COMPLIANT
  v1 = NULL;            // COMPLIANT
  v1 = (struct s1 *)1;  // NON_COMPLIANT
  (void)v1;             // COMPLIANT
}