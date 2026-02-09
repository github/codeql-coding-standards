#include "test.h"
int i = 0;
int i1 = 0;
int i2;             // NON_COMPLIANT - accessed one translation unit
void f1() {}        // Definition
void f2() {}        // Definition
static void f3(){}; // COMPLIANT - internal linkage
void f4() {}        // Definition
void f() {
  i = 0;
  i1 = 0;
  i2 = 0;
  f1();
  f2();
  f3();
}