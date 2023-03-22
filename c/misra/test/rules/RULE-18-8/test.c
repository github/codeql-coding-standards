#define TEST 1

void f(int n, int pa[1][n]) { // NON_COMPLIANT
  int a[1];                   // COMPLIANT
  int x = 1;
  int a1[1 + x];  // NON_COMPLIANT - not integer constant expr
  int a2[n];      // NON_COMPLIANT
  int a3[1][n];   // NON_COMPLIANT
  int a4[] = {1}; // COMPLIANT - not a VLA
  int a5[TEST];   // COMPLIANT
  int a6[1 + 1];  // COMPLIANT
}

void f1(int n, int pa[n]) { // NON_COMPLIANT
}