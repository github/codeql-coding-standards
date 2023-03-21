#include <limits.h>
#include <stddef.h>
#include <stdint.h>

void test_add_simple(signed int i1, signed int i2) {
  i1 + i2; // NON_COMPLIANT - not bounds checked
}

void test_add_precheck(signed int i1, signed int i2) {
  // Style recommended by CERT
  if (((i2 > 0) && (i1 > (INT_MAX - i2))) ||
      ((i2 < 0) && (i1 < (INT_MIN - i2)))) {
    // handle error
  } else {
    i1 + i2; // COMPLIANT - bounds appropriately checked
  }
}

void test_add_precheck_2(signed int i1, signed int i2) {
  if (i1 + i2 < i1) { // Bad overflow check - undefined behavior
    // handle error
  } else {
    i1 + i2; // NON_COMPLIANT
  }
}

void test_add_postcheck(signed int i1, signed int i2) {
  signed int i3 = i1 + i2; // NON_COMPLIANT - signed overflow is undefined
                           // behavior, so checking afterwards is not sufficient
  if (i3 < i1) {
    // handle error
  }
}

void test_sub_simple(signed int i1, signed int i2) {
  i1 - i2; // NON_COMPLIANT - not bounds checked
}

void test_sub_precheck(signed int i1, signed int i2) {
  // Style recomended by CERT
  if ((i2 > 0 && i1 < INT_MIN + i2) || (i2 < 0 && i1 > INT_MAX + i2)) {
    // handle error
  } else {
    i1 - i2; // COMPLIANT - bounds checked
  }
}

void test_sub_postcheck(signed int i1, signed int i2) {
  signed int i3 = i1 - i2; // NON_COMPLIANT - underflow is undefined behavior.
  if (i3 > i1) {
    // handle error
  }
}

void test_mul_simple(signed int i1, signed int i2) {
  i1 *i2; // NON_COMPLIANT
}

void test_mul_precheck(signed int i1, signed int i2) {
  signed long long tmp =
      (signed long long)i1 * (signed long long)i2; // COMPLIANT
  signed int result;

  if (tmp > INT_MAX || tmp < INT_MIN) {
    // handle error
  } else {
    i1 *i2; // COMPLIANT - checked
    result = (signed int)tmp;
  }
}

void test_mul_precheck_2(signed int i1, signed int i2) {
  if (i1 > 0) {
    if (i2 > 0) {
      if (i1 > (INT_MAX / i2)) {
        return; // handle error
      }
    } else {
      if (i2 < (INT_MIN / i1)) {
        // handle error
        return; // handle error
      }
    }
  } else {
    if (i2 > 0) {
      if (i1 < (INT_MIN / i2)) {
        // handle error
        return; // handle error
      }
    } else {
      if ((i1 != 0) && (i2 < (INT_MAX / i1))) {
        // handle error
        return; // handle error
      }
    }
  }
  i1 *i2; // COMPLIANT
}

void test_simple_div(signed int i1, signed int i2) {
  if (i2 == 0) {
    // handle error
  } else {
    i1 / i2; // NON_COMPLIANT
  }
}

void test_div_precheck(signed int i1, signed int i2) {
  if ((i2 == 0) || ((i1 == LONG_MIN) && (i2 == -1))) {
    /* Handle error */
  } else {
    i1 / i2; // COMPLIANT
  }
}

void test_simple_rem(signed int i1, signed int i2) {
  if (i2 == 0) {
    // handle error
  } else {
    i1 % i2; // NON_COMPLIANT
  }
}

void test_rem_precheck(signed int i1, signed int i2) {
  if ((i2 == 0) || ((i1 == LONG_MIN) && (i2 == -1))) {
    /* Handle error */
  } else {
    i1 % i2; // COMPLIANT
  }
}

void test_simple_left_shift(signed int i1, signed int i2) {
  i1 << i2; // NON_COMPLIANT
}

/* Returns the number of set bits */
size_t popcount(uintmax_t num);

#define PRECISION(umax_value) popcount(umax_value)

void test_left_shift_precheck(signed int i1, signed int i2) {
  if ((i1 < 0) || (i2 < 0) || (i2 >= PRECISION(UINT_MAX)) ||
      (i1 > (INT_MAX >> i2))) {
    // handle error
  } else {
    i1 << i2; // COMPLIANT
  }
}

void test_simple_negate(signed int i1) {
  -i1; // NON_COMPLIANT
}

void test_negate_precheck(signed int i1) {
  if (i1 == INT_MIN) {
    // handle error
  } else {
    -i1; // COMPLIANT
  }
}