#include <stddef.h>
#include <stdio.h>
#include <string.h>

struct s1 {
  int x, y, z;
};
struct s1 v1;

int *restrict g1;
int *restrict g2;
void test_global_local_1() {
  int *restrict i1 = g1; // COMPLIANT
  int *restrict i2 = g2; // COMPLIANT
  int *restrict i3 = i2; // NON_COMPLIANT
}

int *restrict g3;
int *restrict g4;
void test_global_local_2() {
  // The second assignment in this block is non-compliant for subtle reasons.
  //
  // If we assume that `test_global_local_2` is only called once, then `g3` and
  // `g4` will likely point to different values and therefore `i1` and `i2` do
  // not alias each other. from g3 to g4 is too late to cause an issue. This was
  // how this query worked under the old dataflow library.
  //
  // However, if we assume this function is called more than once, then the
  // assignment that causes `g3` and `g4` to have the same value, at the end of
  // this function, can predate the assignments that initialize `i1` and `i2`
  // within this function, leading to aliasing that violates the rule. This is
  // how the new dataflow library handles this case.
  int *restrict i1 = g3; // COMPLIANT
  int *restrict i2 = g4; // NON_COMPLIANT
  g3 = g4;               // NON_COMPLIANT
}

int *restrict g5;
int *restrict g6;
void test_global_local_3() {
  int *restrict i2 = g5; // COMPLIANT
  int *restrict i3 = g6; // COMPLIANT
  {
    int *restrict i4;
    int *restrict i5;
    int *restrict i6;
    i4 = g5;        // COMPLIANT -- first assignment within this block
    i4 = (void *)0; // COMPLIANT
    i5 = g5;        // NON_COMPLIANT - block rather than statement scope matters
    i4 = g5;        // NON_COMPLIANT
    i6 = g6;        // COMPLIANT -- first assignment within this block
  }
}

int *restrict g1_1;
int *g2_1;
void test_global_local_4() {
  g1_1 = g2_1; // COMPLIANT
}

void test_structs() {
  struct s1 *restrict p1 = &v1;
  int *restrict px = &v1.x; // NON_COMPLIANT
  {
    int *restrict py;
    int *restrict pz;
    py = &v1.y; // COMPLIANT
    py = (int *)0;
    pz = &v1.z; // NON_COMPLIANT - block rather than statement scope matters
    py = &v1.y; // NON_COMPLIANT
  }
}

void copy(int *restrict p1, int *restrict p2, size_t s) {
  for (size_t i = 0; i < s; ++i) {
    p2[i] = p1[i];
  }
}

void test_restrict_params() {
  int i1 = 1;
  int i2 = 2;
  copy(&i1, &i1, 1); // NON_COMPLIANT
  copy(&i1, &i2, 1); // COMPLIANT

  int x[10];
  int *px = &x[0];
  copy(&x[0], &x[1], 1);       // COMPLIANT - non overlapping
  copy(&x[0], &x[1], 2);       // NON_COMPLIANT - overlapping
  copy(&x[0], (int *)x[0], 1); // COMPLIANT - non overlapping
  copy(&x[0], px, 1);          // NON_COMPLIANT - overlapping
}

void test_strcpy() {
  char s1[] = "my test string";
  char s2[] = "my other string";
  strcpy(&s1, &s1 + 3); // NON_COMPLIANT
  strcpy(&s2, &s1);     // COMPLIANT
}

void test_memcpy() {
  char s1[] = "my test string";
  char s2[] = "my other string";
  memcpy(&s1, &s1 + 3, 5); // NON_COMPLIANT
  memcpy(&s2, &s1 + 3, 5); // COMPLIANT
}

void test_memmove() {
  char s1[] = "my test string";
  char s2[] = "my other string";
  memmove(&s1, &s1 + 3, 5); // COMPLIANT - memmove is allowed to overlap
  memmove(&s2, &s1 + 3, 5); // COMPLIANT
}

void test_scanf() {
  char s1[200] = "%10s";
  scanf(&s1, &s1 + 4); // NON_COMPLIANT
}

// TODO also consider the following:
// strncpy(), strncpy_s()
// strcat(), 	strcat_s()
// strncat(),	strncat_s()
// strtok_s()