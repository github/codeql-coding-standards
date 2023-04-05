

enum { ARRAY_SIZE = 100 };

static int arr[ARRAY_SIZE];

void test_fixed_wrong() {
  arr + 101; // NON_COMPLIANT
}

void test_fixed_right() {
  arr + 2; // COMPLIANT
}

void test_no_check(int index) {
  arr + index; // NON_COMPLIANT
}

void test_invalid_check(int index) {
  if (index < ARRAY_SIZE) {
    arr + index; // NON_COMPLIANT - `index` could be negative
  }
}

void test_valid_check(int index) {
  if (index > 0 && index < ARRAY_SIZE) {
    arr + index; // COMPLIANT - `index` cannot be negative
  }
}

void test_valid_check_by_type(unsigned int index) {
  if (index < ARRAY_SIZE) {
    arr + index; // COMPLIANT - `index` cannot be be negative
  }
}