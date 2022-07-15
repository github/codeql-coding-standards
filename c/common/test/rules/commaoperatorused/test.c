#include <stdlib.h>
int f1();

void f2() {
  int l1 = 10;
  int l2 = (l1++, ++l1); // NON_COMPLIANT
  f1();                  // COMPLIANT
}
