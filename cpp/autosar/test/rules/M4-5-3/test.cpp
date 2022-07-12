void test() {
  char c;

  c = c;  // COMPLIANT
  c == c; // COMPLIANT
  c != c; // COMPLIANT
  c &c;   // COMPLIANT

  !c;      // NON_COMPLIANT
  ~c;      // NON_COMPLIANT
  ++c;     // NON_COMPLIANT
  c++;     // NON_COMPLIANT
  --c;     // NON_COMPLIANT
  c--;     // NON_COMPLIANT
  1 && c;  // NON_COMPLIANT
  1 || c;  // NON_COMPLIANT
  1 + c;   // NON_COMPLIANT
  1 - c;   // NON_COMPLIANT
  1 / c;   // NON_COMPLIANT
  1 * c;   // NON_COMPLIANT
  1 << c;  // NON_COMPLIANT
  1 >> c;  // NON_COMPLIANT
  1 | c;   // NON_COMPLIANT
  1 ^ c;   // NON_COMPLIANT
  c += c;  // NON_COMPLIANT
  c -= c;  // NON_COMPLIANT
  c *= c;  // NON_COMPLIANT
  c /= c;  // NON_COMPLIANT
  c ^= c;  // NON_COMPLIANT
  c %= c;  // NON_COMPLIANT
  c |= c;  // NON_COMPLIANT
  c &= c;  // NON_COMPLIANT
  c <<= c; // NON_COMPLIANT
  c >>= c; // NON_COMPLIANT
}

void test_wchar_t() {
  wchar_t c;

  c = c;  // COMPLIANT
  c == c; // COMPLIANT
  c != c; // COMPLIANT
  c &c;   // COMPLIANT

  !c;      // NON_COMPLIANT
  ~c;      // NON_COMPLIANT
  ++c;     // NON_COMPLIANT
  c++;     // NON_COMPLIANT
  --c;     // NON_COMPLIANT
  c--;     // NON_COMPLIANT
  1 && c;  // NON_COMPLIANT
  1 || c;  // NON_COMPLIANT
  1 + c;   // NON_COMPLIANT
  1 - c;   // NON_COMPLIANT
  1 / c;   // NON_COMPLIANT
  1 * c;   // NON_COMPLIANT
  1 << c;  // NON_COMPLIANT
  1 >> c;  // NON_COMPLIANT
  1 | c;   // NON_COMPLIANT
  1 ^ c;   // NON_COMPLIANT
  c += c;  // NON_COMPLIANT
  c -= c;  // NON_COMPLIANT
  c *= c;  // NON_COMPLIANT
  c /= c;  // NON_COMPLIANT
  c ^= c;  // NON_COMPLIANT
  c %= c;  // NON_COMPLIANT
  c |= c;  // NON_COMPLIANT
  c &= c;  // NON_COMPLIANT
  c <<= c; // NON_COMPLIANT
  c >>= c; // NON_COMPLIANT
}