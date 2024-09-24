#include "stdlib.h"

void f1(); // COMPLIANT
int f2(); // COMPLIANT
_Noreturn void f3(); // COMPLIANT
_Noreturn int f4(); // NON-COMPLIANT

void f5() { // COMPLIANT
}

int f6() { // COMPLIANT
  return 0;
}

_Noreturn void f7() { // COMPLIANT
  abort();
}

_Noreturn int f8() { // NON-COMPLIANT
  abort();
  return 0;
}

_Noreturn void* f9(); // NON-COMPLIANT