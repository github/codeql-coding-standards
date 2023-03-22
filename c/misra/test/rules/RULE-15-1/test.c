void test_goto() {
  int x = 1;

  goto label1; // NON_COMPLIANT

label1:

  x = 2;
}