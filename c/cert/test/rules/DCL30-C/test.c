char *f(void) {
  char a[1];
  return a; // NON_COMPLIANT
}

char f1(void) {
  char a1[1];
  a1[0] = 'a';
  return a1[0]; // COMPLIANT
}

void f2(char **param) {
  char a2[1];
  a2[0] = 'a';
  *param = a2; // NON_COMPLIANT
}

const char *g;
void f3(void) {
  const char a3[] = "test";
  g = a3; // NON_COMPLIANT
}

void f4(void) {
  const char a4[] = "test";
  const char *p = a4; // COMPLIANT
}

#include <stdlib.h>
void f5(void) {
  const char a5[] = "test";
  g = a5; // COMPLIANT[FALSE_POSITIVE]
  g = NULL;
}

char *f6(void) {
  char a6[10];
  return a6 + 3; // NON_COMPLIANT
}

struct S {
  char x;
};

char *f7(void) {
  struct S s;
  return &s.x; // NON_COMPLIANT
}

char *f8(char *p) {
  return p; // COMPLIANT
}

void f9(void) {
  char x;
  char *p = f8(&x); // COMPLIANT
}
