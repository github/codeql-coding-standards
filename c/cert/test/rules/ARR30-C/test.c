

enum { ARRAY_SIZE = 100 };

static int arr[ARRAY_SIZE];

void test_fixed_wrong(void) {
  arr + 101; // NON_COMPLIANT
}

void test_fixed_right(void) {
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

void test_dereference_pointer_arithmetic_const(void) {
  short ptr16[10];
  *(ptr16 - 1);  // NON_COMPLIANT - offset is negative
  *(ptr16 + 5);  // COMPLIANT
  *(ptr16 + 11); // NON_COMPLIANT - offset is too large
  *(ptr16 - 11); // NON_COMPLIANT - offset is negative
}

void test_array_expr_const(void) {
  int arr[10];
  arr[-1];  // NON_COMPLIANT - offset is negative
  arr[5];   // COMPLIANT
  arr[11];  // NON_COMPLIANT - offset is too large
  arr[-11]; // NON_COMPLIANT - offset is negative
}