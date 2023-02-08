void f1() {
  const int a = 3;
  int *aa;

  aa = &a;
  *aa = 100; // NON_COMPLIANT
}

void f1a() {
  const int a = 3;
  int *aa;

  aa = &a; // COMPLIANT
}

void f2() {
  int a = 3;
  int *aa;
  a = 3;

  aa = &a;
  *aa = a;
  *aa = &a;
}

void f4a(int *a) {
  *a = 100; // NON_COMPLIANT
}

void f4b(int *a) {}

void f4() {
  const int a = 100;
  int *p1 = &a; // COMPLIANT
  const int **p2;

  *p2 = &a; // COMPLIANT

  f4a(p1);  // COMPLIANT
  f4a(*p2); // COMPLIANT
}

void f5() {
  const int a = 100;
  int *p1 = &a; // COMPLIANT
  const int **p2;

  *p2 = &a; // COMPLIANT

  f4b(p1);
  f4b(*p2);
}

#include <string.h>

void f6a() {
  char *p;
  const char c = 'A';
  p = &c;
  *p = 0; // NON_COMPLIANT
}

void f6b() {
  const char **cpp;
  char *p;
  const char c = 'A';
  cpp = &p;
  *cpp = &c;
  *p = 0; // NON_COMPLIANT[FALSE_NEGATIVE]
}

const char s[] = "foo"; // source
void f7() {
  *(char *)s = '\0'; // NON_COMPLIANT
}

const char *f8(const char *pathname) {
  char *slash;
  slash = strchr(pathname, '/');
  if (slash) {
    *slash++ = '\0'; // NON_COMPLIANT
    return slash;
  }
  return pathname;
}