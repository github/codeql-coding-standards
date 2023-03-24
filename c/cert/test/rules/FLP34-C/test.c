#include <float.h>
#include <limits.h>
#include <math.h>
#include <stddef.h>
#include <stdint.h>

void test_no_guard(float f) {
  int i = f; // NON_COMPLIANT
}

void test_fixed_narrow_range(float f) {
  if (f > 0.0f && f < 100.0f) {
    int i = f; // COMPLIANT
  }
}

/* Returns the number of set bits */
size_t popcount(uintmax_t num) {
  size_t precision = 0;
  while (num != 0) {
    if (num % 2 == 1) {
      precision++;
    }
    num >>= 1;
  }
  return precision;
}
#define PRECISION(umax_value) popcount(umax_value)

void test_precision_check(float f) {
  if (isnan(f) || PRECISION(INT_MAX) < log2(fabs(f)) ||
      (f != 0.0F && fabs(f) < FLT_MIN)) {
    /* Handle error */
  } else {
    int i = f; // COMPLIANT
  }
}

void test_precision_check_double(double f) {
  if (isnan(f) || PRECISION(INT_MAX) < log2f(fabsf(f)) ||
      (f != 0.0F && fabsf(f) < FLT_MIN)) {
    /* Handle error */
  } else {
    int i = f; // COMPLIANT
  }
}

void test_precision_check_long_double(long double f) {
  if (isnan(f) || PRECISION(INT_MAX) < log2l(fabsl(f)) ||
      (f != 0.0F && fabsl(f) < FLT_MIN)) {
    /* Handle error */
  } else {
    int i = f; // COMPLIANT
  }
}