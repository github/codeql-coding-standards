// Enum with contiguous range 0..2
enum Foo { FOO_A, FOO_B, FOO_C };

// Enum with non-contiguous range
enum Bar { BAR_A, BAR_B = 3, BAR_C };

void test_unconstrained_cast(int x) {
  Foo f = (Foo)x; // NON_COMPLIANT
}

void test_range_check(int x) {
  if (x >= 0) {
    Foo f = (Foo)x; // NON_COMPLIANT - no constrainted upper bound
    Bar b = (Bar)x; // NON_COMPLIANT - no constrainted upper bound
    if (x <= 3) {
      Foo f2 = (Foo)x; // NON_COMPLIANT - no constrainted upper bound
      Bar b2 = (Bar)x; // NON_COMPLIANT - no constrainted upper bound
    }
    if (x <= 2) {
      Foo f2 = (Foo)x; // COMPLIANT - in contiguous range 0..2
      Bar b2 = (Bar)x; // NON_COMPLIANT - not contiguous
    }
  }
}

void test_bitwise_or(Foo f) {
  Foo f2 = (Foo)(f | 0x2); // NON_COMPLIANT - could be 0x3
  Foo f3 = (Foo)(f | 0x4); // NON_COMPLIANT
}

void test_constant() {
  int x = 0;
  Foo f = (Foo)x;  // COMPLIANT - fixed value
  Bar b = (Bar)x;  // COMPLIANT - fixed value
  Foo f2 = (Foo)0; // COMPLIANT - fixed value
  Bar b2 = (Bar)0; // COMPLIANT - fixed value
  int y = 1;
  Foo f3 = (Foo)y; // COMPLIANT - fixed value
  Bar b3 = (Bar)y; // NON_COMPLIANT - not one of the vals
  Foo f4 = (Foo)1; // COMPLIANT - fixed value
  Bar b4 = (Bar)1; // NON_COMPLIANT - not one of the vals
}