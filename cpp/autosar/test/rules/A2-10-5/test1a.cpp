namespace n1 {
static int g1 = 0;
}

static int g2;      // COMPLIANT
static int g3 = 1;  // NON_COMPLIANT
static void f1(){}; // NON_COMPLIANT
