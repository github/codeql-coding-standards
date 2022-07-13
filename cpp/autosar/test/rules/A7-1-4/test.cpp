
void test_register() {

  register int x = 0; // NON_COMPLIANT

  ++x;
  int y = 0; // COMPLIANT

  ++y;
}