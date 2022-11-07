#include <stdalign.h>
#include <stddef.h>

void test_direct_cast_alignment() {
  char c1 = 1;   // assuming 1-byte alignment
  (char *)&c1;   // COMPLIANT
  (short *)&c1;  // NON_COMPLIANT
  (int *)&c1;    // NON_COMPLIANT
  (long *)&c1;   // NON_COMPLIANT
  (float *)&c1;  // NON_COMPLIANT
  (double *)&c1; // NON_COMPLIANT

  short s1 = 1;  // assuming 2-byte alignment
  (char *)&s1;   // COMPLIANT
  (short *)&s1;  // COMPLIANT
  (int *)&s1;    // NON_COMPLIANT
  (long *)&s1;   // NON_COMPLIANT
  (float *)&c1;  // NON_COMPLIANT
  (double *)&c1; // NON_COMPLIANT

  int i1 = 1;    // assuming 4-byte alignment
  (char *)&i1;   // COMPLIANT
  (short *)&i1;  // COMPLIANT
  (int *)&i1;    // COMPLIANT
  (float *)&c1;  // COMPLIANT
  (long *)&i1;   // NON_COMPLIANT - assuming 8 byte alignment for longs
  (double *)&c1; // NON_COMPLIANT

  float f1 = 1;  // assuming 4-byte alignment
  (char *)&f1;   // COMPLIANT
  (short *)&f1;  // COMPLIANT
  (int *)&f1;    // COMPLIANT
  (float *)&f1;  // COMPLIANT
  (long *)&f1;   // NON_COMPLIANT
  (double *)&f1; // NON_COMPLIANT

  long l1 = 1;   // assuming 8-byte alignment
  (char *)&l1;   // COMPLIANT
  (short *)&l1;  // COMPLIANT
  (int *)&l1;    // COMPLIANT
  (float *)&c1;  // COMPLIANT
  (long *)&l1;   // COMPLIANT
  (double *)&c1; // COMPLIANT

  double d1 = 1; // assuming 8-byte alignment
  (char *)&d1;   // COMPLIANT
  (short *)&d1;  // COMPLIANT
  (int *)&d1;    // COMPLIANT
  (float *)&d1;  // COMPLIANT
  (long *)&d1;   // COMPLIANT
  (double *)&d1; // COMPLIANT
}

void custom_aligned_types() {
  alignas(int) char c1 = 1;
  (char *)&c1;   // COMPLIANT
  (short *)&c1;  // COMPLIANT
  (int *)&c1;    // COMPLIANT
  (float *)&c1;  // COMPLIANT
  (long *)&c1;   // NON_COMPLIANT
  (double *)&c1; // NON_COMPLIANT

  alignas(32) char c2 = 1;
  (char *)&c2;   // COMPLIANT
  (short *)&c2;  // COMPLIANT
  (int *)&c2;    // COMPLIANT
  (float *)&c2;  // COMPLIANT
  (long *)&c2;   // NON_COMPLIANT
  (double *)&c2; // NON_COMPLIANT
}

void test_via_void_direct() {
  char c1 = 1;
  void *v1 = &c1;
  (char *)v1;   // COMPLIANT
  (short *)v1;  // NON_COMPLIANT
  (int *)v1;    // NON_COMPLIANT
  (float *)v1;  // NON_COMPLIANT
  (long *)v1;   // NON_COMPLIANT
  (double *)v1; // NON_COMPLIANT

  short s1 = 1;
  void *v2 = &s1;
  (char *)v2;   // COMPLIANT
  (short *)v2;  // COMPLIANT
  (int *)v2;    // NON_COMPLIANT
  (float *)v2;  // NON_COMPLIANT
  (long *)v2;   // NON_COMPLIANT
  (double *)v2; // NON_COMPLIANT

  int i1 = 1;
  void *v3 = &i1;
  (char *)v3;   // COMPLIANT
  (short *)v3;  // COMPLIANT
  (int *)v3;    // COMPLIAN
  (float *)v3;  // COMPLIANT
  (long *)v3;   // NON_COMPLIANT - assuming 8 byte alignment for longs
  (double *)v3; // NON_COMPLIANT - but only on x64

  float f1 = 1;
  void *v4 = &f1;
  (char *)v4;   // COMPLIANT
  (short *)v4;  // COMPLIANT
  (int *)v4;    // COMPLIANT
  (float *)v4;  // COMPLIANT
  (long *)v4;   // NON_COMPLIANT - assuming 8 byte alignment for longs
  (double *)v4; // NON_COMPLIANT

  long l1 = 1;
  void *v5 = &l1;
  (char *)v5;   // COMPLIANT
  (short *)v5;  // COMPLIANT
  (int *)v5;    // COMPLIANT
  (float *)v5;  // COMPLIANT
  (long *)v5;   // COMPLIANT
  (double *)v5; // COMPLIANT

  double d1 = 1;
  void *v6 = &d1;
  (char *)v6;   // COMPLIANT
  (short *)v6;  // COMPLIANT
  (int *)v6;    // COMPLIANT
  (float *)v6;  // COMPLIANT
  (long *)v6;   // COMPLIANT
  (double *)v6; // COMPLIANT
}

int *cast_away(void *v) {
  return (int *)v; // compliance depends on context
}

void test_via_void_indirect() {
  char c1 = 1;
  cast_away((void *)c1); // NON_COMPLIANT

  int i1 = 1;
  cast_away((void *)i1); // COMPLIANT
}

struct S1 {
  char c1;
  unsigned char data[8];
};

struct S2 {
  char c1;
  alignas(size_t) unsigned char data[8];
};

void test_struct_alignment() {
  S1 s1;
  (size_t *)&s1.data; // NON_COMPLIANT

  S2 s2;
  (size_t *)&s2.data; // COMPLIANT
}