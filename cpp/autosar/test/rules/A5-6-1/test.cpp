void test_literals() {
  int a = 1 / 0;   // NON_COMPLIANT
  int b = 1 / 0L;  // NON_COMPLIANT
  int c = 1 / 0U;  // NON_COMPLIANT
  int d = 1 / 0.0; // NON_COMPLIANT

  int s = 1 % 0;  // NON_COMPLIANT
  int t = 1 % 0L; // NON_COMPLIANT
  int u = 1 % 0U; // NON_COMPLIANT

  int x = 1 / 1; // COMPLIANT
  int y = 1 % 1; // COMPLIANT
}

void test_constants() {
  const int const_zero = 0;
  int a = 1 / const_zero; // NON_COMPLIANT
  int b = 1 % const_zero; // NON_COMPLIANT

  const int const_one = 1;
  int c = 1 / const_one; // COMPLIANT
  int d = 1 % const_one; // COMPLIANT
}

void test_macro() {
#define ID(x) x
#define ZERO 0
  int a = 1 / ZERO;  // NON_COMPLIANT
  int b = 1 % ZERO;  // NON_COMPLIANT
  int c = 1 / ID(0); // NON_COMPLIANT
  int d = 1 % ID(0); // NON_COMPLIANT

#define ONE 1
  int e = 1 / ONE;   // COMPLIANT
  int f = 1 % ONE;   // COMPLIANT
  int g = 1 / ID(1); // COMPLIANT
  int h = 1 % ID(1); // COMPLIANT
}