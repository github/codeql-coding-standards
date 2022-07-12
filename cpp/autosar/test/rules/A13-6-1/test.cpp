void test_digit_separators() {
  // Decimal literals
  3'000'000;  // COMPLIANT - correct spacing
  3000000;    // COMPLIANT - no spacing separators
  3'000000;   // NON_COMPLIANT - missing separator
  3'00'00'00; // NON_COMPLIANT - right and wrong separators
  300'00'00;  // NON_COMPLIANT - only wrong

  // Hexadecimal
  0xA0'A0'A0'A0; // COMPLIANT - correct spacing
  0xA0A0A0A0;    // COMPLIANT - no spacing separators
  0xA0A0'A0A0;   // NON_COMPLIANT - missing separators
  0xA0'A0A'0A0;  // NON_COMPLIANT - right and wrong separators
  0xA0A0A'0A0;   // NON_COMPLIANT - only wrong

  // Binary
  0b0101'0101;     // COMPLIANT - correct spacing
  0b01010101;      // COMPLIANT - no spacing separators
  0b01010101'1010; // NON_COMPLIANT - missing separators
  0b01'01'01'01;   // NON_COMPLIANT - right and wrong separators
  0b010'1010'1;    // NON_COMPLIANT - only wrong

  // Floating point
  1.1'000'000e10;  // COMPLIANT - correct spacing
  1.1'000'000e10;  // COMPLIANT - no spacing separators
  1.1000'000e10;   // NON_COMPLIANT - missing separators
  1.10'00'000e10;  // NON_COMPLIANT - right and wrong separators
  1.1'000'000e1'0; // NON_COMPLIANT - right and wrong separators
  1.10'000'00e10;  // NON_COMPLIANT - only wrong
  1.1000000e1'0;   // NON_COMPLIANT - only wrong

  '9'; // ' does not represent a digit sequence separator
}