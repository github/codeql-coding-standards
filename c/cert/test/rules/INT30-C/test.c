#include <limits.h>

void test_add_simple(unsigned int i1, unsigned int i2) {
  i1 + i2;  // NON_COMPLIANT - not bounds checked
  i1 += i2; // NON_COMPLIANT - not bounds checked
}

void test_add_precheck(unsigned int i1, unsigned int i2) {
  if (UINT_MAX - i1 < i2) {
    // handle error
  } else {
    i1 + i2;  // COMPLIANT - bounds checked
    i1 += i2; // COMPLIANT - bounds checked
  }
}

void test_add_precheck_2(unsigned int i1, unsigned int i2) {
  if (i1 + i2 < i1) {
    // handle error
  } else {
    i1 + i2;  // COMPLIANT - bounds checked
    i1 += i2; // COMPLIANT - bounds checked
  }
}

void test_add_postcheck(unsigned int i1, unsigned int i2) {
  unsigned int i3 = i1 + i2; // COMPLIANT - checked for overflow afterwards
  if (i3 < i1) {
    // handle error
  }
  i1 += i2; // COMPLIANT - checked for overflow afterwards
  if (i1 < i2) {
    // handle error
  }
}

void test_ex2(unsigned int i1, unsigned int i2) {
  unsigned int ci1 = 2;
  unsigned int ci2 = 3;
  ci1 + ci2;     // COMPLIANT, compile time constants
  i1 + 0;        // COMPLIANT
  i1 += 0;       // COMPLIANT
  i1 - 0;        // COMPLIANT
  i1 -= 0;       // COMPLIANT
  UINT_MAX - i1; // COMPLIANT - cannot be smaller than 0
  i1 * 1;        // COMPLIANT
  i1 *= 1;       // COMPLIANT
  if (0 <= i1 && i1 < 32) {
    UINT_MAX >> i1; // COMPLIANT
  }
}

void test_ex3(unsigned int i1, unsigned int i2) {
  i1 << i2; // COMPLIANT - by EX3
}

void test_sub_simple(unsigned int i1, unsigned int i2) {
  i1 - i2;  // NON_COMPLIANT - not bounds checked
  i1 -= i2; // NON_COMPLIANT - not bounds checked
}

void test_sub_precheck(unsigned int i1, unsigned int i2) {
  if (i1 < i2) {
    // handle error
  } else {
    i1 - i2;  // COMPLIANT - bounds checked
    i1 -= i2; // COMPLIANT - bounds checked
  }
}

void test_sub_postcheck(unsigned int i1, unsigned int i2) {
  unsigned int i3 = i1 - i2; // COMPLIANT - checked for wrap afterwards
  if (i3 > i1) {
    // handle error
  }
  i1 -= i2; // COMPLIANT - checked for wrap afterwards
  if (i1 > i2) {
    // handle error
  }
}