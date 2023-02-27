#include <stdlib.h>

void test_null(int p1) {
  int *l1 = (void *)0;

  if (p1 > 10) {
    // l1 is only conditionally initialized
    l1 = malloc(10 * sizeof(int));
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

  free(l1); // COMPLIANT - free of `NULL` is not undefined behavior
}

void test_default_value_init() {
  int *l1; // indeterminate and thus invalid but non-null state

  *l1; // COMPLIANT - considered an uninitialized pointer,
       // not a null pointer
}