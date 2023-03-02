#include <tgmath.h>
void f2();
void f1() {
  int i = 2;
  sqrt(i); // NON_COMPLIANT
  float f = 0.5;
  sin(f); // NON_COMPLIANT

  float complex dc = 1 + 0.5 * I;
  float complex z = sqrt(dc); // NON_COMPLIANT
  creal(z);                   // NON_COMPLIANT
  cimag(z);                   // NON_COMPLIANT
  f2();
}
