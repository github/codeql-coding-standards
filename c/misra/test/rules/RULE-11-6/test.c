void f1(void) {
  int v1 = 0;
  void *v2 = (void *)v1; // NON_COMPLIANT
  unsigned char v3 = 0;
  v2 = (void *)v3;  // NON_COMPLIANT
  v2 = (void *)&v3; // COMPLIANT
  v1 = (int)v2;     // NON_COMPLIANT
  v1 = (int)v3;     // COMPLIANT
}