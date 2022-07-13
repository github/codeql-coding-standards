#define NULL 0

void test_throw_null() {
  throw NULL; // NON_COMPLIANT
}

void test_throw_null_brackets() {
  throw(NULL); // NON_COMPLIANT
}

void test_throw_zero() {
  throw 0; // COMPLIANT
}