#include "test_shared.h"

struct s1 {
  float v1;
}; // COMPLIANT

struct s2 {
  float v1;
}; // NON_COMPLIANT

struct s3 {
  float v1;
}; // COMPLIANT

void *f1(struct s1 *p1) {
  int v1 = p1->v1;
  return (void *)p1;
}

void *f2(struct s2 *p1) { return (void *)p1; }

void *f3(struct only_test2_s1 *p1) {
  int v1 = (*p1).v1;
  return (void *)p1;
}

void *f4(struct only_test2_s1 *p1) {
  int v1 = p1->v1;
  return (void *)p1;
}

void *f5(struct only_test2_s2 *p1) { return (void *)p1; }

void *f6(union shared_u1 *p1) { return (void *)p1; }

void *f7(union shared_u2 *p1) {
  int v1 = p1->v1;
  return (void *)p1;
}

void *f8(void) {
  struct s3 v1;
  return (void *)0;
}

void *f9(struct s3 *p1) { return (void *)p1; }