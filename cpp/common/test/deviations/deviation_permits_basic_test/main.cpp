int getX() { return 5; }

int getY() { return 5; }

int main(int argc, char **argv) {
  int x = 0;      // COMPLIANT[DEVIATED]
  getX();         // NON_COMPLIANT
  getY();         // a-0-1-2-deviated
  long double d1; // NON_COMPLIANT (A0-4-2)
  long double d2; // a-0-4-2-deviation COMPLIANT[DEVIATED]
  return 0;
}
