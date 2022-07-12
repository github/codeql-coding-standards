void test_non_zero_octal() {
  '\0';    // COMPLIANT - octal zero escape sequence permitted
  '\012';  // NON_COMPLIANT
  '\054';  // NON_COMPLIANT
  '\0149'; // NON_COMPLIANT
  0;       // COMPLIANT - octal literal zero permitted
  012;     // NON_COMPLIANT
  054;     // NON_COMPLIANT
  "\0";    // COMPLIANT - octal zero escape sequence permitted
  "\012";  // NON_COMPLIANT
  "\054";  // NON_COMPLIANT
  "\0149"; // NON_COMPLIANT
}