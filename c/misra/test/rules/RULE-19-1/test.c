#include <string.h>

int o[10];
void g(void) {

  o[2] = o[0]; // COMPLIANT

  memcpy(&o[1], &o[0], 2); // NON_COMPLIANT
  memcpy(&o[2], &o[0], 2); // COMPLIANT
  memcpy(&o[2], &o[1], 2); // NON_COMPLIANT
  memcpy(o + 1, o, 2);     // NON_COMPLIANT
  memcpy(o + 2, o, 2);     // COMPLIANT
  memcpy(o + 2, o + 1, 2); // NON_COMPLIANT

  // Exception 1
  int *p = &o[0];
  int *q = &o[0];

  *p = *q;                 // COMPLIANT
  memcpy(&o[0], &o[0], 2); // COMPLIANT
  memcpy(o, o, 2);         // COMPLIANT

  // Exception 2
  memmove(&o[1], &o[0], 2u * sizeof(o[0])); // COMPLIANT
}

struct s1 {
  int m1[10];
};
struct s2 {
  int m1;
  struct s1 m2;
};
union u {
  struct s1 m1;
  struct s2 m2;
} u1;

typedef struct {
  char buf[8];
} Union_t;
union {
  unsigned char uc[24];
  struct {
    Union_t prefix;
    Union_t suffix;
  } fnv;
  struct {
    unsigned char padding[16];
    Union_t suffix;
  } diff;
} u2;

void test_unions() {
  u1.m2.m2 = u1.m1; // NON_COMPLIANT

  memcpy(&u1.m2.m2, &u1.m1, sizeof(u1.m1)); // NON_COMPLIANT
  memcpy(&u2.diff.suffix, &u2.fnv.suffix, sizeof(u2.fnv.suffix)); // COMPLIANT
}