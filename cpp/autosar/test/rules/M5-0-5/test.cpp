void test_non_const() {
  float f;
  int i;

  i = f;        // NON_COMPLIANT
  f = i + f;    // NON_COMPLIANT
  f = i;        // NON_COMPLIANT
  i = i + 1.0f; // NON_COMPLIANT - the non-constant i is converted to float and
                // the non-constant expression i + 1.0f is converted to int.
  f = static_cast<float>(i); // COMPLIANT
  f = (float)(i);            // COMPLIANT
}

void test_const() {
  float f;
  int i;

  f = f + 1;                     // NON_COMPLIANT
  f = f + (-1);                  // NON_COMPLIANT
  f = f + static_cast<float>(1); // COMPLIANT
  i = i + 1.0f; // COMPLIANT - the non-constant i is converted to float and the
                // non-constant expression i + 1.0f is converted to int.
}