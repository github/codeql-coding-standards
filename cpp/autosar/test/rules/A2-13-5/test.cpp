void test_lower_case_hex() {
  0xA123F123;  // COMPLIANT
  0xA1234f123; // NON_COMPLIANT
  0xa1234f123; // NON_COMPLIANT
}