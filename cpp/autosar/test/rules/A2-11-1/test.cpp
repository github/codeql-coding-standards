void test_volatile() {
  // NON_COMPLIANT
  volatile int x = 1;

  // COMPLIANT
  int y = 2;

  y += x;
}