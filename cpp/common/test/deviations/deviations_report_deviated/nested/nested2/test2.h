int getZ() { return 5; }

void test2() {
  int x = 0; // COMPLIANT[DEVIATED]
  getZ(); // COMPLIANT[DEVIATED]
}