#include <stdlib.h>

int g1;

int f1(int p1) {
  int l1 = p1 + 1; // Non-persistent side-effect for the caller of f1.

  return l1;
}

int f2(int p1) {
  static int l1 = 0;
  l1 = p1 + 1; // Persistent side-effect for the caller of f2.

  return l1;
}

int f3(int p1) {
  g1 = p1 + 1; // Persistent side-effect for the caller of f3.

  return g1;
}

void test(int p1) {
  if (g1 && f1(p1) > 0) // COMPLIANT
  {
  }

  if (g1 && f2(p1) > 0) // NON_COMPLIANT
  {
  }

  if (g1 && f3(p1) > 0) // NON_COMPLIANT
  {
  }

  volatile int l1, l2;
  if ((l1 == 0) || (l2 == 0)) // NON_COMPLIANT
  {
  }

  int (*fp)(int) = NULL;
  (fp != NULL) && (*fp)(0); // NON_COMPLIANT[FALSE_NEGATIVE]
}