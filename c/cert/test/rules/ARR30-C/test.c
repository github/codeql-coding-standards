

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

void test_local_buffer_invalid_check(int index) {
  char buffer[ARRAY_SIZE];

  if (index < ARRAY_SIZE) {
    char *ptr = buffer + index; // NON_COMPLIANT - `index` could be negative
  }

  if (index >= 0 && index < ARRAY_SIZE + 2) {
    char *ptr = buffer + index; // NON_COMPLIANT - `index` could be too large
  }

  if (index >= 0 && index < ARRAY_SIZE) {
    char *ptr = buffer + index; // COMPLIANT
  }
}