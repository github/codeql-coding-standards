// semmle-extractor-options:--clang -std=c11 -nostdinc
void static_contract(int values[static 3]); // NON_COMPLIANT (MISRA-C-2012 only)
void ordinary_contract(int values[3]);      // COMPLIANT

void array_calls(void) {
  int enough[3] = {0, 0, 0}; // COMPLIANT
  int small[2] = {0, 0};     // COMPLIANT
  static_contract(enough);   // COMPLIANT
  static_contract(small);    // NON_COMPLIANT
  ordinary_contract(enough); // COMPLIANT
  ordinary_contract(small);  // NON_COMPLIANT
}