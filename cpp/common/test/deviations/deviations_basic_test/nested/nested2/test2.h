int getZ2() { return 5; }

void test2() {
  int x = 0; // COMPLIANT[DEVIATED]
  getZ2();   // COMPLIANT[DEVIATED]
}