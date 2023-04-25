#include <stdlib.h>

typedef float AF12[12];

struct S1 {
  char a[8];
};
struct S2 {
  struct S1 *s1;
};
struct S3 {
  struct S1 s1;
  int i1;
};
struct S4 {
  AF12 af12;
};

struct S5 {
  int i1;
  struct S1 *s1;
};

struct S1 get_s1(void) {
  struct S1 s1;
  return s1;
}

struct S1 *get_s1_ptr(void) {
  struct S1 *s1 = malloc(sizeof(struct S1));
  return s1;
}

struct S2 get_s2(void) {
  struct S2 s2;
  return s2;
}

struct S3 get_s3(void) {
  struct S3 s3;
  return s3;
}

struct S4 get_s4(void) {
  struct S4 s4;
  return s4;
}

struct S5 get_s5(void) {
  struct S5 s5;
  return s5;
}

void test_field_access(void) {
  struct S1 s1 = get_s1();
  struct S2 s2 = get_s2();
  struct S3 s3 = get_s3();
  struct S4 s4 = get_s4();

  s1.a[0] = 'a';     // COMPLIANT
  s2.s1->a[0] = 'a'; // COMPLIANT
  s3.s1.a[0] = 'a';  // COMPLIANT
  s4.af12[0] = 0.0f; // COMPLIANT

  (void)get_s1().a;     // NON_COMPLIANT
  (void)get_s2().s1->a; // COMPLIANT
  (void)get_s3().s1.a;  // NON_COMPLIANT
  (void)get_s3().i1;    // NON_COMPLIANT - even if scalar type accessed
  (void)get_s4().af12;  // NON_COMPLIANT
  (void)get_s5().s1->a; // COMPLIANT
}