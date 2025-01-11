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

  // Casting to a pointer to a type of the same size doesn't invalidate the
  // analysis
  unsigned int *p12 = (unsigned int *)l1;
  void *p13 = &p12[3]; // COMPLIANT
  void *p14 = &p12[4]; // NON_COMPLIANT

  // Casting to a char* is effectively a new array of length sizeof(T)
  unsigned char *p15 = (unsigned char *)l1;
  void *p16 = &p15[4]; // COMPLIANT
  void *p17 = &p15[5]; // NON_COMPLIANT

  long l2[3];
  unsigned char *p18 = (unsigned char *)&l2;
  void *p19 = &p18[8]; // COMPLIANT
  void *p20 = &p18[9]; // NON_COMPLIANT

  // Casting to a pointer to a differently sized type that isn't char
  // invalidates analysis
  int l3[3];
  long *p21 = (long*)&l1;
  void *p22 = &p21[0];   // COMPLIANT
  // Not compliant, but we shouldn't detect it, but we do for the wrong reason:
  void *p23 = &p21[100]; // NON_COMPLIANT[FALSE_NEGATIVE][FALSE_POSITIVE]
}