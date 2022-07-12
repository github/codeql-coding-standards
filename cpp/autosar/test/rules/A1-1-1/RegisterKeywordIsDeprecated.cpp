void test() {
  register int a; // NON_COMPLIANT
  int b;          // COMPLIANT
}

int foo(register int a) { // NON_COMPLIANT
  return a;
}