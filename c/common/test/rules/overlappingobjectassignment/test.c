#include <stdint.h>

void f(void) {
  union {
    int i;
    long l;
  } u = {0};

  u.l = u.i; // NON_COMPLIANT
}
