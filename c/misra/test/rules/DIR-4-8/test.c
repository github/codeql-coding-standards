#include "test.h"
#include "test_shared.h"
struct s3 {
  int v1;
  struct s3_1 {
    int a;
  } v2; // COMPLIANT
};      // COMPLIANT

struct s4 {
  int v1;
}; // NON_COMPLIANT

typedef struct s3 s3_t;
typedef struct s4 s4_t;

void *f1(struct s1 *p1) { return (void *)p1; }

void *f2(struct s2 *p1) {
  int v1 = p1->v1;
  return p1;
}

s3_t *f3(s3_t *p1) {
  int v1 = p1[0].v1;
  return p1;
}

void *f4(s4_t *p1) { return p1; }

void *f5(struct only_test1_s1 *p1) {
  int v1 = p1->v1;
  return (void *)p1;
}

void *f6(struct shared_s1 *p1) {
  int v1 = p1->v1;
  return (void *)p1;
}

void *f7(union shared_u1 *p1) { return (void *)p1; }

void *f8(union shared_u2 *p1) {
  int v1 = p1->v1;
  return (void *)p1;
}