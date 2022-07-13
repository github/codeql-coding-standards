extern void f1(int, int);

int f2(void);
int f3(void);

int g1;

void test() {
  int l1;
  int l2[10] = {0};

  l1 = l1 + 1;
  l2[l1] = l1; // COMPLIANT

  l1 = ++l1 + 1; // NON_COMPLIANT
  l2[l1++] = l1; // NON_COMPLIANT

  f1(l1, l1++); // NON_COMPLIANT

  f1(f2(), f3()); // NON_COMPLIANT
}

int f2(void) { return g1 + 1; }

int f3(void) {
  g1 = 0;
  return g1;
}