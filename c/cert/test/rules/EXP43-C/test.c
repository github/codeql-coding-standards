#include <stddef.h>
#include <stdio.h>
#include <string.h>

int *restrict g1;
int *restrict g2;
int *restrict g1_1;
int *g2_1;

struct s1 {
  int x, y, z;
};
struct s1 v1;

void test_global_local() {
  int *restrict i1 = g1; // COMPLIANT
  int *restrict i2 = g2; // COMPLIANT
  int *restrict i3 = i2; // NON_COMPLIANT
  g1 = g2;               // NON_COMPLIANT
  i1 = i2;               // NON_COMPLIANT
  {
    int *restrict i4;
    int *restrict i5;
    int *restrict i6;
    i4 = g1;        // COMPLIANT
    i4 = (void *)0; // COMPLIANT
    i5 = g1;        // NON_COMPLIANT - block rather than statement scope matters
    i4 = g1;        // NON_COMPLIANT
    i6 = g2;        // COMPLIANT
  }
}

void test_global_local_1() {
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