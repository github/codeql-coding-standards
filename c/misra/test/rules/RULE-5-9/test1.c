static int g;  // COMPLIANT
static int g1; // NON_COMPLIANT

static void f() { // NON_COMPLIANT
  int g;          // NON_COMPLIANT
  int g2;         // COMPLIANT
}

void f1() { // COMPLIANT
  int g;    // NON_COMPLIANT
  int g2;   // COMPLIANT
}