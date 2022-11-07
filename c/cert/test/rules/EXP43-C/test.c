#include <stddef.h>
#include <string.h>

int *restrict g1;
int *restrict g2;

void test_global_local() {
  int *restrict i1 = g1; // COMPLIANT
  int *restrict i2 = g2; // COMPLIANT
  int *restrict i3 = i2; // NON_COMPLIANT
  g1 = g2;               // NON_COMPLIANT
  i1 = i2;               // NON_COMPLIANT
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
  copy(x[0], x[1], 1); // COMPLIANT - non overlapping
  copy(x[0], x[1], 2); // NON_COMPLIANT - overlapping
}

void test_strcpy() {
  char s1[] = "my test string";
  char s2[] = "my other string";
  strcpy(&s1, &s1 + 3); // NON_COMPLIANT
  strcpy(&s2, &s1);     // COMPLIANT
}

void test_strcpy_s() {
  char s1[] = "my test string";
  char s2[] = "my other string";
  strcpy_s(&s1, &s1 + 3);         // NON_COMPLIANT
  strcpy_s(&s2, sizeof(s2), &s1); // COMPLIANT
}

void test_memcpy() {
  char s1[] = "my test string";
  char s2[] = "my other string";
  memcpy(&s1, &s1 + 3, 5); // NON_COMPLIANT
  memcpy(&s2, &s1 + 3, 5); // COMPLIANT
}

void test_memcpy_s() {
  char s1[] = "my test string";
  char s2[] = "my other string";
  memcpy_s(&s1, sizeof(s1), &s1 + 3, 5); // NON_COMPLIANT
  memcpy_s(&s2, sizeof(s2), &s1 + 3, 5); // COMPLIANT
}

void test_memmove() {
  char s1[] = "my test string";
  char s2[] = "my other string";
  memmove(&s1, &s1 + 3, 5); // COMPLIANT
  memmove(&s2, &s1 + 3, 5); // COMPLIANT
}

void test_scanf() {
  char s1[200] = "%10s";
  scanf(&s2, &s2 + 4); // NON_COMPLIANT
}

// TODO also consider the following:
// strncpy(), strncpy_s()
// strcat(), 	strcat_s()
// strncat(),	strncat_s()
// strtok_s()