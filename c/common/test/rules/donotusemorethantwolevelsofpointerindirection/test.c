typedef int *intptr_t;

typedef struct S {
  int *a;      // COMPLIANT
  intptr_t b;  // COMPLIANT
  intptr_t *c; // COMPLIANT
  intptr_t **d // NON_COMPLIANT
} S_t;

S_t s1;    // COMPLIANT
S_t *s2;   // COMPLIANT
S_t **s3;  // COMPLIANT
S_t ***s4; // NON_COMPLIANT

void f1(int *p1,                 // COMPLIANT
        int **p2,                // COMPLIANT
        int ***p3,               // NON_COMPLIANT
        int **const *const par5, // NON_COMPLIANT
        int *par6[],             // COMPLIANT
        int **par7[]             // NON_COMPLIANT
);