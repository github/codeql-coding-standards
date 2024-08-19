
void g();
void test_nested_slashstar() {
  /* Comment before
  g();
  /* Comment after */ // NON_COMPLIANT
  /* Compliant */ // COMPLIANT
}
