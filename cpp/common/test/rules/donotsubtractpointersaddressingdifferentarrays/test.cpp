void f1() {
  int l1[10];
  int l2[10];
  int *p1 = &l1[9];
  int *p2 = &l2[10];
  int *p3 = p2;
  int *p4 = p3;
  int diff;

  diff = p1 - l1; // COMPLIANT
  diff = p2 - l2; // COMPLIANT
  diff = p1 - p2; // NON_COMPLIANT
  diff = p4 - l1; // NON_COMPLIANT
  diff = p4 - l2; // COMPLIANT
}
