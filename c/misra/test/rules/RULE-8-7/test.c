#include "test.h"
int i2;           // NON_COMPLIANT - accessed one translation unit
static void f3(); // COMPLIANT - internal linkage
extern void f3(); // COMPLIANT - internal linkage
void f() {
  i = 0;
  i1 = 0;
  i2 = 0;
  f1();
  f2();
  f3();
}