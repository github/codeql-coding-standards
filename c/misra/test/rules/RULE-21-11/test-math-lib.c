#include <math.h>
#include <stdio.h>
void f2();
void f1() {
  int i = 2;
  sqrt(i); // COMPLIANT
  float f = 0.5;
  sin(f); // COMPLIANT
  f2();
}
