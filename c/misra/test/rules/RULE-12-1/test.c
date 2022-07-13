void test_sizeof() {
  int l1 = sizeof(int);    // COMPLIANT
  int l2 = sizeof(l1 + 1); // COMPLIANT
  int l3 = sizeof l1 + 1;  // NON_COMPLIANT
}

extern int f1(int);
extern int f2(int, int);

void test_precedence(int p1, int p2) {
  int l1, l2, l3, l4;
  l1 + l2;               // COMPLIANT
  l1 + l2 + l3;          // COMPLIANT
  (l1 + l2) + l3;        // COMPLIANT
  l1 + l2 - l3 + l4;     // COMPLIANT
  (l1 + l2) - (l3 + l4); // COMPLIANT

  int l5 = f2(l1 + l2, l3); // COMPLIANT

  int l6 = (l1 == l2) ? l3 : (l3 - l4); // COMPLIANT
  int l7 = l1 == l2 ? l3 : l3 - l4;     // NON_COMPLIANT

  if (l1 && l2 && l3) // COMPLIANT
  {
  }

  if (l1 > l2 && l3) // NON_COMPLIANT
  {
  }

  if (l1 && l3 < l4 && l5) // NON_COMPLIANT
  {
  }

  int l8 = f1(l1) + l2; // COMPLIANT
}