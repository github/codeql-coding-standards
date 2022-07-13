#include <stdint.h>

typedef struct s1 s1;

void f1(void) {
  int *v1 = (int *)(s1 *)0;   // COMPLIANT
  char *v2 = (char *)v1;      // COMPLIANT
  void *v3 = (void *)0;       // COMPLIANT
  s1 *v4 = (s1 *)v3;          // COMPLIANT
  s1 *v5 = (s1 *)v2;          // COMPLIANT
  void *v6 = (void *)v5;      // COMPLIANT
  int16_t *v7 = (int8_t *)v1; // NON_COMPLIANT
  int *v8 = (int *)0;         // COMPLIANT
  v8 = v2;                    // NON_COMPLIANT
  v8 = (int *)(short *)v2;    // NON_COMPLIANT
}