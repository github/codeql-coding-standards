// NOTICE: THE TEST CASES BELOW ARE ALSO INCLUDED IN THE C TEST CASE AND
// CHANGES SHOULD BE REFLECTED THERE AS WELL.
void test_non_zero_octal() {
  0;   // COMPLIANT - octal literal zero permitted
  012; // NON_COMPLIANT
  054; // NON_COMPLIANT
}