#include <limits.h>
#include <stdint.h>
#include <stdlib.h>

// arbitrary excessive stack alloc size: USHRT_MAX bytes
#define VLA_MAX_SIZE USHRT_MAX

void test_vla_constants(void) {
  size_t uninitialized;
  size_t zero = 0;
  size_t two = 2;
  size_t max_num = VLA_MAX_SIZE / sizeof(char);

  char vla0[uninitialized];     // NON_COMPLIANT - uninitialized
  char vla1[zero];              // NON_COMPLIANT - zero-sized array
  char vla2[zero * two];        // NON_COMPLIANT - zero-sized array
  char vla3[zero + two];        // COMPLIANT
  char vla4[zero - two];        // NON_COMPLIANT - wrap-around
  char vla5[max_num];           // COMPLIANT
  char vla6[max_num + two];     // NON_COMPLIANT - too large
  char vla7[max_num + 1 - two]; // COMPLIANT;
}

void test_vla_bounds8(uint8_t num8, int8_t snum8) {
  char vla0[num8];      // NON_COMPLIANT - size could be `0`
  char vla1[num8 + 1];  // COMPLIANT
  char vla2[num8 - 1];  // NON_COMPLIANT - wrap-around
  char vla3[snum8];     // NON_COMPLIANT - unbounded
  char vla4[snum8 + 1]; // NON_COMPLIANT - unbounded
  char vla5[snum8 - 1]; // NON_COMPLIANT - unbounded

  if (num8 == 0) {
    char vla6[num8];     // NON_COMPLIANT - size is 0
    char vla7[num8 + 1]; // COMPLIANT - size is 1
    char vla8[num8 - 1]; // NON_COMPLIANT - wrap-around
  }

  if (num8 > 0) {
    char vla6[num8];     // COMPLIANT
    char vla7[num8 + 1]; // COMPLIANT
    char vla8[num8 - 1]; // NON_COMPLIANT - unbounded
  }
}

void test_overflowed_size(int8_t ssize) {
  if (ssize > 1) {
    int8_t tmp = ssize * 2;
    char vla0[ssize];     // COMPLIANT
    char vla1[ssize * 2]; // COMPLIANT - type promotion
    char vla2[tmp];       // NON_COMPLIANT - potential overflow
    char vla3[++ssize];   // NON_COMPLIANT - potential overflow
  }
}

void test_vla_bounds(size_t num) {
  int vla0[num];     // NON_COMPLIANT - size could be greater than max
  int vla1[num + 1]; // NON_COMPLIANT - unbounded
  int vla2[num - 1]; // NON_COMPLIANT - unbounded

  if (num == 0) {
    int vla6[num];     // NON_COMPLIANT - size is 0
    int vla7[num + 1]; // COMPLIANT - size is 1
    int vla8[num - 1]; // NON_COMPLIANT - unbounded
  }

  if (num > 0) {
    int vla6[num];     // NON_COMPLIANT - size could be greater than max
    int vla7[num + 1]; // NON_COMPLIANT - unbounded
    int vla8[num - 1]; // NON_COMPLIANT - unbounded
  }

  if (VLA_MAX_SIZE / sizeof(int) >= num) {
    int vla6[num];     // NON_COMPLIANT - size could be 0
    int vla7[num + 1]; // NON_COMPLIANT - size greater than max
    int vla8[num - 1]; // NON_COMPLIANT - unbounded

    if (num >= 100) {
      int vla9[num];      // COMPLIANT
      int vla10[num + 1]; // NON_COMPLIANT - unbounded
      int vla11[num - 1]; // COMPLIANT
    }
  }

  size_t num2 = num + num;
  if (num2 > 0 && num2 < 100) {
    int vla12[num2]; // NON_COMPLIANT - bad post-check
  }

  signed int num3 = INT_MAX;
  num3++;
  num3 += INT_MAX;
  if (num3 > 0 && num3 < 100) {
    int vla13[num3]; // NON_COMPLIANT - overflowed
  }

  int num4;
  if (num > 2) {
    num4 = num - 2; // potentially changed value
  }
  int vla14[num4]; // NON_COMPLIANT - unbounded
}

void test_vla_typedef(size_t x, size_t y) {
  typedef int VLA[x][y]; // NON_COMPLIANT
  // ...
  // (void)sizeof(VLA);
}

void test_multidimensional_vla(size_t n, size_t m) {

  if (VLA_MAX_SIZE / sizeof(int) >= (n * m)) { // wrapping check
    int vla0[n][m];                            // NON_COMPLIANT - size too large
  }

  if (m > 0 && n > 0 && VLA_MAX_SIZE / sizeof(int) >= n &&
      VLA_MAX_SIZE / sizeof(int) >= m && VLA_MAX_SIZE / sizeof(int) >= n * m) {
    int vla1[n][m];         // COMPLIANT[FALSE_POSITIVE]
    int vla2[n - 1][m - 1]; // NON_COMPLIANT - unbounded
    int vla3[n][n];         // NON_COMPLIANT - n*n not checked
    int vla4[n][n][n];      // NON_COMPLIANT - unbounded

    if (VLA_MAX_SIZE / (sizeof(int) * n) >= n * n) {
      int vla5[n][n][n];     // COMPLIANT[FALSE_POSITIVE]
      int vla6[m][m][m];     // NON_COMPLIANT - size too large
      int vla7[n][n][n + 1]; // NON_COMPLIANT - size too large
    }

    if (m > 0 && m <= 100 && n > 0 && n <= 100) {
      int vla08[n][m];         // COMPLIANT
      int vla09[n][n];         // COMPLIANT
      int vla10[n][n - 98][n]; // NON_COMPLIANT - unbounded
      if (n == 100) {
        int vla11[n][n - 98][n]; // COMPLIANT
      }
      int vla12[n][m][n]; // NON_COMPLIANT
    }
  }
}

void test_fvla(int size,
               int data[size][size]) { // COMPLIANT - not an actual VLA
  return;
}