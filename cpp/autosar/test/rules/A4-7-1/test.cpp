int test_addition_no_bounds_check(int x, int y) {
  return x + y; // NON_COMPLIANT - no bounds checking
}

unsigned int test_addition_bounds_check(unsigned int x, unsigned int y) {
  if (x < 100 && y < 100) {
    return x + y; // COMPLIANT - valid bounds check
  }
  return 0;
}

unsigned int test_addition_valid_overflow_check(unsigned int x,
                                                unsigned int y) {
  if (x + y > x) {
    return x + y; // COMPLIANT - valid bounds check
  }
  return 0;
}

int test_addition_invalid_overflow_check(int x, int y) {
  if (x + y < x) {
    return x + y; // NON_COMPLIANT - bounds check isn't valid!
  }
  return 0;
}

short test_addition_invalid_overflow_check(short x, short y) {
  if (x + y < x) {
    // This case is not covered by the current queries, because it only
    // overflows when the expression is converted back to a short to be
    // returned. M5-0-6 would report the implicit cast of the result back to the
    // return value instead
    return x + y; // NON_COMPLIANT[FALSE_NEGATIVE]
  }
  return 0;
}

void test_addition_loop_bound(unsigned int base, unsigned int size) {
  if (size > 0) {
    int n = size - 1;
    for (int i = 0; i < n; i++) {
      base + i; // COMPLIANT - `i` is bounded
    }
  }
}

void test_addition_invalid_loop_bound(unsigned int base, unsigned int j,
                                      unsigned int size) {
  if (size > 0) {
    int n = size - 1;
    for (int i = 0; i < n; i++) {
      base + j; // NON_COMPLIANT - guards are not related
    }
  }
}