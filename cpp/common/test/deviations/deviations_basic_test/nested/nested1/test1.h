int getZ1() { return 5; }

void test1() {
  int x = 0; // COMPLIANT[DEVIATED]
  getZ1();   // COMPLIANT[DEVIATED]
}