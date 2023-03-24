#include <string.h>

struct S1 {
  int i;
};

struct S2 {
  float f;
};

struct S3 {
  struct S2 s2;
};

struct S4 {
  struct S3 s3;
};

struct S5 {
  union {
    float f1;
    int i1;
  };
};

void test_float_memcmp(float f1, float f2) {
  memcmp(&f1, &f2, sizeof(float)); // NON_COMPLIANT
}

void test_struct_int_memcmp(struct S1 s1a, struct S1 s1b) {
  memcmp(&s1a, &s1b, sizeof(struct S1)); // COMPLIANT
}

void test_struct_float_memcmp(struct S2 s2a, struct S2 s2b) {
  memcmp(&s2a, &s2b, sizeof(struct S2)); // NON_COMPLIANT
}

void test_struct_nested_float_memcmp(struct S3 s3a, struct S3 s3b) {
  memcmp(&s3a, &s3b, sizeof(struct S3)); // NON_COMPLIANT
}

void test_struct_nested_nested_float_memcmp(struct S4 s4a, struct S4 s4b) {
  memcmp(&s4a, &s4b, sizeof(struct S4)); // NON_COMPLIANT
}

void test_union_nested_float_memcmp(struct S5 s5a, struct S5 s5b) {
  memcmp(&s5a, &s5b, sizeof(struct S5)); // NON_COMPLIANT
}