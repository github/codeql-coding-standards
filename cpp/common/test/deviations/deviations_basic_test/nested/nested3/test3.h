int getZ3() { return 5; }

void test3() {
  int x = 0; // COMPLIANT[DEVIATED]
  getZ3();   // NON_COMPLIANT
}