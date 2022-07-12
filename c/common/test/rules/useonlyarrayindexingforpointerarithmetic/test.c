struct S {
  int m[3];
};

void f(int p1[], struct S *p2) {
  int l1 = 0;
  int *l2;
  int l3[10];
  int *l4;

  l2 = l2 + 1; // NON_COMPLIANT
  l2[0] = 0;   // NON_COMPLIANT - l2 is not declared as array
  l4 = &l2[0]; // NON_COMPLIANT - l2 is not declared as array
  l3[l1] = 0;  // COMPLIANT
  l4 = &l3[1]; // COMPLIANT
  l4 = l3;
  *(l4 + 1) = 0; // NON_COMPLIANT
  l1 = l4[0];    // COMPLIANT
  l1 = p1[0];    // COMPLIANT

  int *l5 = p2->m;
  l1 = l5[0]; // COMPLIANT
}
