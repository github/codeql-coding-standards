void test() {
  int l1, l2;
  int l3[1];

  l1 = l2; // COMPLIANT

  if (l1 = 1) // NON_COMPLIANT
  {
  }

  l1 = l3[l2 = 0]; // NON_COMPLIANT

  l1 = l2 = 0; // NON_COMPLIANT
}