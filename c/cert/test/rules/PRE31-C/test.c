#include <stdio.h>

#define safe(x) ((x) + 1)
#define unsafe(x) (x) * (x)

void test_crement() {
  int i = 0;
  safe(i++);   // COMPLIANT
  unsafe(i++); // NON_COMPLIANT
  safe(i--);   // COMPLIANT
  unsafe(i--); // NON_COMPLIANT
}

int addOne(int x) { return x + 1; }
int writeX(int x) {
  printf("%d", x);
  return x;
}

int external();

void test_call() {
  safe(addOne(10));   // COMPLIANT
  safe(external());   // COMPLIANT
  safe(writeX(10));   // COMPLIANT
  unsafe(addOne(10)); // COMPLIANT
  unsafe(external()); // NON_COMPLIANT
  unsafe(writeX(10)); // NON_COMPLIANT
}