int getZ() { return 5; }

int alt() {
  int x = 0;       // COMPLIANT[DEVIATED]
  getZ();          // NON_COMPLIANT
  long double dd1; // NON_COMPLIANT (A0-4-2)

  long double [[codeql::autosar_deviation(
      "a-0-4-2-deviation")]] dd3; // COMPLIANT[DEVIATED]

  [[codeql::autosar_deviation(
      "a-0-4-2-deviation")]] long double dd4; // COMPLIANT[DEVIATED]

  [[codeql::autosar_deviation("a-0-4-2-deviation")]] {
    long double d7; // COMPLIANT[DEVIATED]
    getZ();         // NON_COMPLIANT (A0-1-2)
    long double d8; // COMPLIANT[DEVIATED]
    getZ();         // NON_COMPLIANT (A0-1-2)
    long double d9; // COMPLIANT[DEVIATED]
  }
  long double d10; // NON_COMPLIANT (A0-4-2)
  [[codeql::autosar_deviation("a-0-4-2-deviation")]] {
    long double d11; // COMPLIANT[DEVIATED]
    getZ();          // NON_COMPLIANT (A0-1-2)
    long double d12; // COMPLIANT[DEVIATED]
    getZ();          // NON_COMPLIANT (A0-1-2)
    long double d13; // COMPLIANT[DEVIATED]
  }
  long double d14; // NON_COMPLIANT (A0-4-2)
  getZ();          // NON_COMPLIANT (A0-1-2)
  [[codeql::autosar_deviation("a-0-4-2-deviation")]]
  for (long double d15 = 0.0; true;) {} // COMPLIANT[DEVIATED]
  for (long double d16 = 0.0; true;) {  // NON_COMPLIANT (A0-4-2)
  }
  return 0;
}

[[codeql::autosar_deviation("a-0-4-2-deviation")]]
int alt2() {
  int x = 0;       // COMPLIANT[DEVIATED]
  getZ();          // NON_COMPLIANT
  long double dd1; // COMPLIANT[DEVIATED]
  [[codeql::autosar_deviation(
      "a-0-4-2-deviation")]] long double dd2; // COMPLIANT[DEVIATED]
}