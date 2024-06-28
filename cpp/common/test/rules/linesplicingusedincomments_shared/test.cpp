void test_cpp_multiline() {
  int i = 0;
  // NON_COMPLIANT \
  i++;
  // COMPLIANT
  i++;
  /*
   * COMPLIANT \
   */
}