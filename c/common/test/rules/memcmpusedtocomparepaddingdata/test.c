#include <string.h>

struct S1 {
  unsigned char buffType;
  int size;
};

struct S2 {
  unsigned char buff[8];
};

void f1(const struct S1 *s1, const struct S1 *s2) {
  if (!memcmp(s1, s2, sizeof(struct S1))) { // NON_COMPLIANT
  }
}

void f2(const struct S2 *s1, const struct S2 *s2) {
  if (!memcmp(&s1, &s2, sizeof(struct S2))) { // COMPLIANT
  }
}