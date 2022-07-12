
int f1(int *p1) { return *p1++; }
extern int f2();

int g1;

void test(int p1) {
  int l1 = sizeof(int); // COMPLIANT
  volatile int l2;

  int l3 = sizeof(l2); // COMPLIANT - per exception

  int l4 = sizeof(g1++); // NON_COMPLIANT
  int l5 = sizeof(p1++); // NON_COMPLIANT

  int l6 = sizeof(f1(&l1)); // NON_COMPLIANT
  int l7 = sizeof(f2());    // NON_COMPLIANT

  volatile int l8[p1];
  int l9 = sizeof(l8); // NON_COMPLIANT
}
