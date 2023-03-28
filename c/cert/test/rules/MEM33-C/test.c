#include <memory.h>
#include <stdlib.h>

struct s1 {
  int num;
  char b[];
};

struct s2 {
  int a;
  char b[1];
};

void test_alloc(void) {
  struct s1 v1;                   // NON_COMPLIANT
  struct s1 *v2;                  // COMPLIANT
  v2 = malloc(sizeof(struct s1)); // NON_COMPLIANT - size does not include space
                                  // for the flexible array
  struct s1 *v3 =
      malloc(sizeof(struct s1)); // NON_COMPLIANT - size does not include space
                                 // for the flexible array
  struct s1 *v4 = malloc(
      sizeof(struct s1) -
      1); // NON_COMPLIANT - size does not include space for the flexible array
  struct s1 *v5 = malloc(sizeof(struct s1) + 1); // COMPLIANT
  struct s2 v6;                                  // COMPLIANT - no flex array
  struct s2 *v7 = malloc(sizeof(struct s1));     // COMPLIANT - no flex array
}

// calls to this function are never compliant
void test_fa_param(struct s1 p1) {} // NON_COMPLIANT

// calls to this function are always compliant
void test_pfa_param(struct s1 *p1) {} // COMPLIANT

// calls to this function are always compliant
void test_s_param(struct s2 p1) {} // COMPLIANT

void test_fa_params_call(void) {
  struct s1 v1; // NON_COMPLIANT
  struct s1 *v2 = malloc(sizeof(struct s1) + 1);
  test_fa_param(v1);   // NON_COMPLIANT
  test_pfa_param(&v1); // COMPLIANT
  test_pfa_param(v2);  // COMPLIANT
}

void test_copy(struct s1 *p1, struct s1 *p2) {
  struct s1 v1 = *p2; // NON_COMPLIANT
  *p1 = *p2;          // NON_COMPLIANT
  memcpy(p1, p2,
         sizeof(struct s1)); // NON_COMPLIANT - not copying size of array
  memcpy(p1, p2, sizeof(struct s1) + 1);       // COMPLIANT
  memcpy(p1, p2, sizeof(struct s1) + p2->num); // COMPLIANT
}