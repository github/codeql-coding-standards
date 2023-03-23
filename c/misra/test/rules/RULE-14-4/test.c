#include <stdbool.h>
int f1();
void *f2();

void f3() {
  int l1 = 1;
  if (l1) { // NON_COMPLIANT
  }
  if (f1()) { // NON_COMPLIANT
  }
  void *l2 = f2();
  if (l2) { // NON_COMPLIANT
  }
}

void f4() {
  int l1 = 1;
  if ((bool)l1) { // COMPLIANT
  }

  int l2 = 1;
  if ((const bool)l2) { // COMPLIANT
  }

  if (l2 < 3) { // COMPLIANT
  }

  if (true) { // COMPLIANT
  }
}