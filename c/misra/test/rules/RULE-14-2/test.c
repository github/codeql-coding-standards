
#include "stdbool.h"
int g1 = 10;
int f1() { return g1++; }

void f2() {
  for (float f = 0.0F; f < 10.0F; f += 0.2F) { // NON_COMPLIANT
  }
  for (int i = 0; i < 10; i++) { // COMPLIANT
  }
}

void f3() {
  for (int i = 0, j = 0; i < j; i++, j++) { // NON_COMPLIANT
  }
}

void f4() {
  int i, j;
  for (i = 0, j = 0; i < j; i++, j++) { // NON_COMPLIANT
  }
}

void f5() {
  for (int i = 0; i != 10; i += 3) { // NON_COMPLIANT
  }

  for (int i = 0; i != 10; i++) { // COMPLIANT
  }
}

void f7() {
  for (int i = 0; i < 100; i += g1) { // COMPLIANT
  }
}

void f8() {
  for (int x = 0; x < 5; x += f1()) { // NON_COMPLIANT
  }
}

void f9() {
  bool l1 = true;
  for (int x = 0; (x < 5) && l1; ++x) { // COMPLIANT
    l1 = false;
  }
}

bool f10(int p1) { return false; }
void f11() {
  bool p1 = true;
  for (int x = 0; (x < 5); p1 = f10(++x)) { // NON_COMPLIANT
  }
}

void f12() {
  bool l1 = true;
  for (int x = 0; (x < 5) && l1; ++x) { // COMPLIANT
  }
}

void f13() {
  int l1 = 1;
  for (int x = 0; x < 5 && l1 == 9; ++x) { // NON_COMPLIANT
    x = x + 2;
    g1--;
  }
}

void f14() {
  for (int i = 0; i < 10; i += 3) { // COMPLIANT
  }
}