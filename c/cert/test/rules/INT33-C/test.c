#include <limits.h>

void test_simple(signed int i1, signed int i2) {
  i1 / i2; // NON_COMPLIANT
  i1 % i2; // NON_COMPLIANT
}

void test_incomplete_check(signed int i1, signed int i2) {
  if (i1 == INT_MIN && i2 == -1) {
    // handle error
  } else {
    i1 / i2; // NON_COMPLIANT
    i1 % i2; // NON_COMPLIANT
  }
}

void test_complete_check(signed int i1, signed int i2) {
  if (i2 == 0 || (i1 == INT_MIN && i2 == -1)) {
    // handle error
  } else {
    i1 / i2; // COMPLIANT
    i1 % i2; // COMPLIANT
  }
}

void test_unsigned(unsigned int i1, unsigned int i2) {
  if (i2 == 0) {
    // handle error
  } else {
    i1 / i2; // COMPLIANT
    i1 % i2; // COMPLIANT
  }
}