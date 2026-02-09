#include <math.h>
void f(int x) {
  float f1 = 0.0f;
  double d1 = 0.0f;
  sin(f1); // COMPLIANT
  cos(f1); // COMPLIANT
  tan(f1); // COMPLIANT
  sin(d1); // COMPLIANT
  cos(d1); // COMPLIANT
  tan(d1); // COMPLIANT

  if (x < 10) {
    f1 += 3.14;
    d1 += 3.14;
    sin(f1);  // COMPLIANT
    cos(f1);  // COMPLIANT
    tan(f1);  // COMPLIANT
    sin(d1);  // COMPLIANT
    cos(d1);  // COMPLIANT
    tan(d1);  // COMPLIANT
    sin(-f1); // COMPLIANT
    cos(-f1); // COMPLIANT
    tan(-f1); // COMPLIANT
    sin(-d1); // COMPLIANT
    cos(-d1); // COMPLIANT
    tan(-d1); // COMPLIANT
  }

  if (x < 20) {
    f1 = 3.14 * 10;
    d1 = 3.14 * 10;
    sin(f1);  // NON-COMPLIANT
    cos(f1);  // NON-COMPLIANT
    tan(f1);  // NON-COMPLIANT
    sin(d1);  // COMPLIANT
    cos(d1);  // COMPLIANT
    tan(d1);  // COMPLIANT
    sin(-f1); // NON-COMPLIANT
    cos(-f1); // NON-COMPLIANT
    tan(-f1); // NON-COMPLIANT
    sin(-d1); // COMPLIANT
    cos(-d1); // COMPLIANT
    tan(-d1); // COMPLIANT
  }

  if (x < 30) {
    f1 = 3.14 * 100;
    d1 = 3.14 * 100;
    sin(f1);  // NON-COMPLIANT
    cos(f1);  // NON-COMPLIANT
    tan(f1);  // NON-COMPLIANT
    sin(d1);  // NON-COMPLIANT
    cos(d1);  // NON-COMPLIANT
    tan(d1);  // NON-COMPLIANT
    sin(-f1); // NON-COMPLIANT
    cos(-f1); // NON-COMPLIANT
    tan(-f1); // NON-COMPLIANT
    sin(-d1); // NON-COMPLIANT
    cos(-d1); // NON-COMPLIANT
    tan(-d1); // NON-COMPLIANT
  }
}