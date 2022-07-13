//#include <stdio.h>
#include <string.h>

typedef struct {
  int pos;
} FILE;

void f() {
  FILE *pf1;
  FILE *pf2;
  FILE f3;
  pf2 = pf1;    // COMPLIANT
  f3 = *pf2;    // NON_COMPLIANT
  pf1->pos = 0; // NON_COMPLIANT

  memcpy(pf1, pf2, 1); // NON_COMPLIANT
  memcmp(pf1, pf2, 1); // NON_COMPLIANT
}

void f1help(FILE *pf1, FILE *pf2) {
  pf2 = pf1;    // COMPLIANT
  pf1->pos = 0; // NON_COMPLIANT
}
void f1() {
  FILE *pf1;
  FILE *pf2;
  f1help(pf1, pf2);
}
