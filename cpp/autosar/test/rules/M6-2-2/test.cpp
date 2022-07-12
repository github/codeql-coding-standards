void test() {
  float f = 0.0, g = 1.0;
  float *pf = &f;
  double d = 0.0;

  1 == 1;        // COMPLIANT
  true == false; // COMPLIANT
  'a' == 'A';    // COMPLIANT

  0.0 == 0.0; // NON_COMPLIANT
  f == 1.0f;  // NON_COMPLIANT
  f != 1.0;   // NON_COMPLIANT
  f != g;     // NON_COMPLIANT
  *pf == f;   // NON_COMPLIANT
  *pf != *pf; // NON_COMPLIANT
  1.0 == d;   // NON_COMPLIANT
  1 == d;     // NON_COMPLIANT
  d != d;     // NON_COMPLIANT
  f < g;      // NON_COMPLIANT
  g >= f;     // NON_COMPLIANT
  d <= 0.0f;  // NON_COMPLIANT
  d <= *pf;   // NON_COMPLIANT
  1 > 2.0;    // NON_COMPLIANT
}