#include <limits.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
void test_unsigned_to_signed(unsigned int x) {
  (signed int)x; // NON_COMPLIANT - not larger enough to represent all
}

void test_unsigned_to_signed_check(unsigned int x) {
  if (x <= INT_MAX) {
    (signed int)x; // COMPLIANT
  }
}

void test_signed_to_unsigned(signed int x) {
  (unsigned int)x; // NON_COMPLIANT - not large enough to represent all
}

void test_signed_to_unsigned_check(signed int x) {
  if (x >= 0) {
    (unsigned int)x; // COMPLIANT
  }
}

void test_signed_to_unsigned_check2(signed int x) {
  if (x < 0) {
  } else {
    (unsigned int)x; // COMPLIANT
  }
}

void test_signed_loss_of_precision(signed int x) {
  (signed short)x; // NON_COMPLIANT - not large enough to represent all
}

void test_signed_loss_of_precision_check(signed int x) {
  if (x >= SHRT_MIN && x <= SHRT_MAX) {
    (signed short)x; // COMPLIANT
  }
}

void test_signed_loss_of_precision_check2(signed int x) {
  if (x < SHRT_MIN || x > SHRT_MAX) {
  } else {
    (signed short)x; // COMPLIANT
  }
}

void test_unsigned_loss_of_precision(unsigned int x) {
  (unsigned short)x; // NON_COMPLIANT - not large enough to represent all
}

void test_unsigned_loss_of_precision_check(unsigned int x) {
  if (x <= USHRT_MAX) {
    (unsigned short)x; // COMPLIANT
  }
}

void test_unsigned_loss_of_precision_check2(unsigned int x) {
  if (x > USHRT_MAX) {
  } else {
    (unsigned short)x; // COMPLIANT
  }
}

// We create a fake stub here to test the case
// that time_t is an unsigned type.
typedef unsigned int time_t;
time_t time(time_t *seconds);

void test_time_t_check_against_zero(time_t x) {
  time_t now = time(0);
  if (now != -1) { // NON_COMPLIANT[FALSE_NEGATIVE] - there is no conversion
                   // here in our model
  }
  if (now != (time_t)-1) { // COMPLIANT
  }
}

void test_chars() {
  signed int i1 = 'A';
  signed int i2 = 100000;
  signed int i3 = -128;
  signed int i4 = 255;
  signed int i5 = -129;
  signed int i6 = 256;
  (unsigned char)i1; // COMPLIANT
  (unsigned char)i2; // NON_COMPLIANT
  (unsigned char)i3; // COMPLIANT
  (unsigned char)i4; // COMPLIANT
  (unsigned char)i5; // NON_COMPLIANT
  (unsigned char)i6; // NON_COMPLIANT
}

void test_funcs(int *a, size_t n) {
  fputc(4096, stdout); // NON_COMPLIANT
  fputc('A', stdout);  // COMPLIANT
  ungetc(4096, stdin); // NON_COMPLIANT
  ungetc('A', stdin);  // COMPLIANT
  memchr(a, 4096, n);  // NON_COMPLIANT
  memchr(a, 'A', n);   // COMPLIANT
  memset(a, 4096, n);  // NON_COMPLIANT
  memset(a, 0, n);     // COMPLIANT
  // not supported in our stdlib, or in any of the compilers
  // memset_s(a, rn, 4096, n); // NON_COMPLIANT
  // memset_s(a, rn, 0, n);    // COMPLIANT
}

void test_bool(signed int s) {
  (bool)s; // COMPLIANT
}