// Unscoped enum, with no fixed type
// This has a value range of 0..3
enum Foo { FOO_A, FOO_B, FOO_C };

// Scope enum, this has a fixed underlying type of int
enum class Bar { BAR_A, BAR_B, BAR_C };

void test_unconstrained_cast(int x) {
  Foo f = (Foo)x; // NON_COMPLIANT
  Bar b = (Bar)x; // COMPLIANT - value ranges are the same
}

void test_range_check(int x) {
  if (x >= 0) {
    Foo f = (Foo)x; // NON_COMPLIANT - no constrainted upper bound
    if (x <= 3) {
      Foo f2 = (Foo)x; // COMPLIANT - constrainted upper bound
    }
    if (x <= 4) {
      Foo f2 = (Foo)x; // NON_COMPLIANT - if x=4, it's out of bounds
    }
  }
}

void test_unsanitize(Foo f) {
  Foo f2 = (Foo)(f | 0x2); // COMPLIANT
  Foo f3 = (Foo)(f | 0x4); // NON_COMPLIANT
}