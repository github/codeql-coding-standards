extern void f1(int *);

void test(int p1, int p2) {
  volatile int l1;

  int l2[2] = {0, l1};   // NON_COMPLIANT
  int l3[1] = {p1 + p2}; // COMPLIANT
  int l4[1] = {p1++};    // NON_COMPLIANT
  f1((int[1]){p1++});    // NON_COMPLIANT
}