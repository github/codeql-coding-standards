#include <string.h>

extern char a[10];
extern char b[10];

char c[10] = {'a', 'b', 0};
char d[10] = {'a', 'b', 0};

void testCmp(int *p) {
  memcmp("a", "b", 1); // NON_COMPLIANT

  strcpy(a, "a");
  strcpy(b, "b");
  memcmp(a, b, 1); // NON_COMPLIANT

  memcmp(c, d, 1); // NON_COMPLIANT

  char e[10] = {'a', 'b', 0};
  char f[10] = {'a', 'b', 0};

  memcmp(e, f, 1); // NON_COMPLIANT

  memcmp(p, a, 1); // COMPLIANT
  memcmp(a, p, 1); // COMPLIANT

  memcmp(p, c, 1); // COMPLIANT
  memcmp(c, p, 1); // COMPLIANT
}
