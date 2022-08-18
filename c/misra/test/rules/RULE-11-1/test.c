#include <stddef.h>

typedef void (*fp1)(void);
typedef void (*fp2)(int p1);
typedef fp2 (*pfp2)(void);

void f1(void) {
  fp1 v1 = NULL; // COMPLIANT
  fp2 v2 = NULL; // COMPLIANT

  v1 = (fp1 *)v2;        // NON_COMPLIANT
  void *v3 = (void *)v1; // NON_COMPLIANT

  v2 = (fp2 *)0; // NON_COMPLIANT
  v2 = (fp2 *)1; // NON_COMPLIANT

  pfp2 v4;
  (void)(*v4()); // COMPLIANT

  extern void f2(int p1);
  f2(0);                   // COMPLIANT
  fp1 v5 = f2;             // NON_COMPLIANT
  fp2 v6 = f2;             // COMPLIANT
  v5 = v1;                 // COMPLIANT
  v5 = v2;                 // NON_COMPLIANT
  v5 = (void (*)(void))v1; // COMPLIANT
  v5 = (void (*)(void))v2; // NON_COMPLIANT
}