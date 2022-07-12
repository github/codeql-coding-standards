int getY() { return 5; }

void test() {
  int x = 0; // COMPLIANT[DEVIATED]
  getY(); // NON_COMPLIANT
}