#include <limits.h>
#include <math.h>
#include <stddef.h>
#include <stdint.h>

size_t popcount(uintmax_t num);

#define PRECISION(umax_value) popcount(umax_value)

void test_incorrect_precision_check(int e) {
  if (e >= sizeof(unsigned int) * CHAR_BIT) { // NON_COMPLIANT
    // handle error
  } else {
    1 << e;
  }
}

void test_correct_precision_check(int e) {
  if (e >= PRECISION(UINT_MAX)) { // COMPLIANT
    /* Handle error */
  } else {
    1 << e;
  }
}

void test_incorrect_precision_check_cast(float f) {
  if (log2f(fabsf(f)) > sizeof(signed int) * CHAR_BIT) { // NON_COMPLIANT
    // handle error
  } else {
    (signed int)f;
  }
}

void test_correct_precision_check_cast(float f) {
  if (log2f(fabsf(f)) > PRECISION(INT_MAX)) { // COMPLIANT
    /* Handle error */
  } else {
    (signed int)f;
  }
}