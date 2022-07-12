void test_simple_aliasing() {
  int *a;
  int b;
  a = &b; // COMPLIANT - same scope
  {
    int c;
    a = &c; // NON_COMPLIANT - different scope
  }
}