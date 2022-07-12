void f1() {
  int l1[10];
  int l2[10];
  int l3[7];

  int *p0 = l1;
  int *p1 = &l1[0];
  int *p2 = &l1[1];
  int *p3 = &l2[2];

  if (p1 < p2) { // COMPLIANT
  }
  if (p1 < p0) { // COMPLIANT
  }
  if (l1 <= p1) { // COMPLIANT
  }
  if (p1 < l2) { // NON_COMPLIANT
  }
  if (l1 < l2) { // NON_COMPLIANT
  }
  if (p2 < p3) { // NON_COMPLIANT
  }
  if (l2 <= p1) { // NON_COMPLIANT
  }
  if (p1 >= l3) { // NON_COMPLIANT
  }
}