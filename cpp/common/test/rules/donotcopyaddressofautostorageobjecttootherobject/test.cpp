void test_simple_aliasing() {
  int *a;
  int b;
  a = &b; // COMPLIANT - same scope
  {
    int c;
    a = &c; // NON_COMPLIANT - different scope
  }
}

void extra_test_simple_aliasing() {
  int *p;
  {
    int l_a[1];
    p = l_a; // NON_COMPLIANT
  }
}

void extra_test2_simple_aliasing() {
  int *p;
  {
    int *p2 = nullptr;
    int l;

    p2 = &l; // COMPLIANT
    p = p2;  // NON_COMPLIANT
  }
}