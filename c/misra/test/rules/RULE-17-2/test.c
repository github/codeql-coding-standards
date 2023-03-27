void f1();
void f2();
void f4(int p1) { // COMPLIANT
  f1();
}

void f3() {
  f3(); // NON_COMPLIANT
}
void f6() {
  f3(); // NON_COMPLIANT
}

void f5() {
  f2(); // NON_COMPLIANT
}
void f2() {
  f5(); // NON_COMPLIANT
}