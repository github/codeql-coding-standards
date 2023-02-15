#include <stdlib.h>
#include <string.h>

void test_incompatible_arithmetic() {
  float f = 0.0f;
  int *p = (int *)&f; // NON_COMPLIANT - arithmetic types are not compatible
                      // with each other
  (*p)++;

  short s[2];
  (int *)&s; // NON_COMPLIANT

  (short(*)[4]) & s; // NON_COMPLIANT - array of size 2 is not compatible with
                     // array of size 4 (n1570 6.7.6.2 paragraph 7)
  (short(*)[2]) & s; // COMPLIANT

  // char may be signed or unsigned, and so is not compatible with either
  char c1;
  (signed char *)&c1;   // NON_COMPLIANT
  (unsigned char *)&c1; // COMPLIANT - the underlying byte representation is
                        // always compatible
  (char *)&c1;          // COMPLIANT - same type

  // int is defined as signed, so is compatible with all the signed versions
  // (long, short etc. are similar)
  int i1;
  (signed int *)&i1;   // COMPLIANT
  (int *)&i1;          // COMPLIANT
  (signed *)&i1;       // COMPLIANT
  (unsigned int *)&i1; // NON_COMPLIANT
  (const int *)&i1;    // COMPLIANT - adding a const specifier is permitted
}

struct {
  int a;
} * s1;
struct {
  int a;
} * s2;
struct S1 {
  int a;
} * s3;
struct S1 *s4;

void test_incompatible_structs() {
  // s1 and s2 do not have tags, and are therefore not compatible
  s1 = s2; // NON_COMPLIANT
  // s3 tag is inconsistent with s1 tag
  s1 = s3; // NON_COMPLIANT
  s3 = s1; // NON_COMPLIANT
  // s4 tag is consistent with s3 tag
  s3 = s4; // COMPLIANT
  s4 = s3; // COMPLIANT
}

enum E1 { E1A, E1B };
enum E2 { E2A, E2B };

void test_enums() {
  enum E1 e1 = E1A;
  enum E2 e2 = e1; // COMPLIANT
  // Enums are also compatible with one of `char`, a signed integer type or an
  // unsigned integer type. It is implementation defined which is used, so
  // choose an appropriate type below for this test
  (int *)&e1; // COMPLIANT
}

int *void_cast(void *v) { return (int *)v; }

void test_indirect_cast() {
  float f1 = 0.0f;
  void_cast(&f1); // NON_COMPLIANT
  int i1 = 0;
  void_cast(&i1); // COMPLIANT
}

signed f(int y) { return y; }
int g(signed int x) { return x; }

// 6.7.6.3 p15
void test_compatible_functions() {
  signed (*f1)(int) = &g;     // COMPLIANT
  int (*g1)(signed int) = &f; // COMPLIANT
}

struct S2 {
  int a;
  int b;
};

struct S3 {
  int a;
  int b;
};

void test_realloc() {
  struct S2 *s2 = (struct S2 *)malloc(sizeof(struct S2));
  struct S3 *s3 = (struct S3 *)realloc(s2, sizeof(struct S3));
  s3->a; // NON_COMPLIANT
  memset(s3, 0, sizeof(struct S3));
  s3->a; // COMPLIANT
}