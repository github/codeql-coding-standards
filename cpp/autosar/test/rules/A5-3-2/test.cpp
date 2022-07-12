void test_null(int p1) {
  int *l1 = nullptr;

  if (p1 > 10) {
    // l1 is only conditionally initialized
    l1 = new int(10);
  }

  *l1; // NON_COMPLIANT - dereferenced and still null

  if (l1) {
    *l1; // COMPLIANT - null check before dereference
  }

  if (!l1) {
    *l1; // NON_COMPLIANT - dereferenced and definitely null
  } else {
    *l1; // COMPLIANT - null check before dereference
  }

  delete l1; // COMPLIANT - delete of `null` is not undefined behavior
}

void test_default_value_init() {
  int *l1; // default initialization of a type which is neither an array or
           // class type performs no initialization. `l1` will have an
           // indeterminate value, and we represent this as being in an invalid
           // (rather than null) state.

  *l1; // COMPLIANT - considered an uninitialized pointer,
       // not a null pointer

  int *l2{}; // value initialized, which for a pointer will be null

  *l2; // NON_COMPLIANT - dereference of a null pointer
}