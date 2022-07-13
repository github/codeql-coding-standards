void f1(int p1) {
  p1 = 1; // NON_COMPLIANT
}

int g1 = 1;
void f2(int *p1) {
  p1 = &g1; // NON_COMPLIANT
  *p1 = g1; // COMPLIANT
}