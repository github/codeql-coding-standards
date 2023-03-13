#include <stddef.h>

struct s1 {
  int v1, v2, v3;
};

void f2(int p1, int p2) {
  int *v1;
  v1 += p1; // NON_COMPLIANT
  v1 += p2; // COMPLIANT
}

void f1() {
  int v1[10];
  struct s1 *v2;
  size_t offset = offsetof(struct s1, v2);
  size_t size = sizeof(v1);
  int *v3 = (int *)(v2 + offset);       // NON_COMPLIANT
  char *v4 = (char *)v2 + offset;       // COMPLIANT
  v3 = (int *)(((char *)v2) + offset);  // COMPLIANT
  v2++;                                 // COMPLIANT
  v2 += 10;                             // COMPLIANT
  v3 += size;                           // NON_COMPLIANT
  v3++;                                 // COMPLIANT
  v3 += sizeof(v1);                     // NON_COMPLIANT
  (void)v1[sizeof(v1) / sizeof(v1[0])]; // COMPLIANT
  (void)v1[10 / sizeof(v1)];            // NON_COMPLIANT
  v4 += offset;                         // COMPLIANT
  f2(offset, 2);
}
//