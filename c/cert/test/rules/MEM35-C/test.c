#include <stdint.h>
#include <stdlib.h>

#define S1_SIZE 32 // incorrect size for struct S1

struct S1 {
  char f1[S1_SIZE];
  int f2;
};

void sizecheck_test(void) {
  struct S1 *v1 = malloc(S1_SIZE);           // NON_COMPLIANT
  struct S1 *v2 = malloc(sizeof(struct S1)); // COMPLIANT
  struct S1 *v3 = malloc(sizeof(*v2));       // COMPLIANT
  struct S1 *v4 = malloc(sizeof(v4));        // NON_COMPLIANT
  char *v5 = malloc(10);                     // COMPLIANT
}

void sizecheck2_test(size_t len) {
  struct S1 *v1 = malloc(S1_SIZE * 4); // NON_COMPLIANT
  struct S1 *v2 = malloc(S1_SIZE * 4); // NON_COMPLIANT
  struct S1 *v3 = malloc(
      S1_SIZE * 9); // COMPLIANT - erroneous logic, but the size product is an
                    // LCM of S1_SIZE and sizeof(S1) and thus a valid multiple
  long *v4 = malloc(len * sizeof(int)); // NON_COMPLIANT - wrong sizeof type
}

void unsafe_int_test(size_t len) {
  size_t size = len * sizeof(long);
  long *v1 = malloc(len); // COMPLIANT - even could indicate a logic error
  long *v2 = malloc(len * sizeof(long)); // NON_COMPLIANT - unbounded int
  long *v3 = malloc(size);               // NON_COMPLIANT - unbounded int

  if (len > SIZE_MAX / sizeof(*v3)) {
    // overflow/wrapping check
    return;
  }

  long *v4 = malloc(len * sizeof(long)); // COMPLIANT - overflow checked
  long *v5 = malloc(size);               // NON_COMPLIANT - `size` not checked
}
