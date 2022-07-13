
extern volatile int g1;
int f1() { return g1 + 1; }

extern int f2();

int f3() { return 1; }

struct S1 {
  int l1;
};

void test() {
  int l1, l2;

  l2 = l1++; // NON_COMPLIANT

  int l3 = l1;
  l1++; // COMPLIANT

  if ((f1() + --l1) > 0) // NON_COMPLIANT
  {
  }

  if ((f2() + --l1) > 0) // NON_COMPLIANT
  {
  }

  if ((f3() + --l1) > 0) // COMPLIANT
  {
  }

  l3 = (l2 == l2) ? 0 : l1++; // NON_COMPLIANT

  int l4[1] = {0};
  l4[0]++; // COMPLIANT

  struct S1 l5 = {.l1 = 0};
  l5.l1++; // COMPLIANT

  struct S1 *l6;
  l6->l1++; // COMPLIANT

  int *l7 = &l1;
  ++(*l7); // COMPLIANT
  *l7++;   // COMPLIANT
  (*l7)++; // COMPLIANT
}