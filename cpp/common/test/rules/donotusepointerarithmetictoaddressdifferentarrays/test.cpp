void f1() {
  int l1[3];
  int *p1 = &l1[0];
  int *p2 = p1 + 4; // NON_COMPLIANT
  int *p3 = 4 + p1; // NON_COMPLIANT
  int *p4 = &l1[4]; // NON_COMPLIANT
  int *p5, *p6, *p7, *p8;

  p5 = p2 - 1; // COMPLIANT
  p6 = --p2;   // COMPLIANT
  p7 = p3--;   // NON_COMPLIANT
  p8 = p3;     // COMPLIANT[FALSE_POSITIVE]

  int *p9 =
      p1 + 3; // COMPLIANT - points to an element on beyond the end of the array
  int *p10 =
      3 + p1; // COMPLIANT - points to an element on beyond the end of the array
  int *p11 =
      &l1[3]; // COMPLIANT - points to an element on beyond the end of the array
}