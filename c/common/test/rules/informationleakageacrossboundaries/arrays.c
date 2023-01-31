#include <stddef.h>
#include <string.h>

unsigned long copy_to_user(void *to, const void *from, unsigned long n);

struct WithArray {
  int a[2];
};

void forget_array() {
  struct WithArray wa;
  copy_to_user(0, &wa, sizeof wa); // NON_COMPLIANT
}

void write_partial_array() {
  struct WithArray wa;
  wa.a[0] = 1;
  copy_to_user(0, &wa, sizeof wa); // NON_COMPLIANT[FALSE NEGATIVE]
}

void write_full_array() {
  struct WithArray wa;
  wa.a[0] = 1;
  wa.a[1] = 1;
  copy_to_user(0, &wa, sizeof wa); // COMPLIANT
}

struct WithArray2D {
  int a[2][1];
};

void forget_array2d() {
  struct WithArray2D wa;
  copy_to_user(0, &wa, sizeof wa); // NON_COMPLIANT
}

void write_partial_array2d() {
  struct WithArray2D wa;
  wa.a[0][0] = 1;
  copy_to_user(0, &wa, sizeof wa); // NON_COMPLIANT[FALSE NEGATIVE]
}

void write_full_array2d() {
  struct WithArray2D wa;
  wa.a[0][0] = 1;
  wa.a[1][0] = 1;
  copy_to_user(0, &wa, sizeof wa); // COMPLIANT
}

// A pointer field allows mostly the same syntactic operations as an array
// field, but the semantics are completely different.
struct WithPointer {
  int *a;
};

void pointer_array_expression() {
  struct WithPointer wa;
  wa.a[0] = 1;
  copy_to_user(0, &wa, sizeof wa); // NON_COMPLIANT
}

// TODO: test a struct in an array